//
//  MABGTimer.m
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MABGTimer.h"

#import <dispatch/dispatch.h>
#import <objc/runtime.h>


@interface _MABGTimer : NSObject
{
    id _obj;
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
}

- (id)initWithObject: (id)obj;
- (void)setDelay: (NSTimeInterval)delay block: (void (^)(id))block;
- (void)performBlockOnQueue: (dispatch_block_t)block;
- (void)cancel;

@end

@implementation _MABGTimer

- (id)initWithObject: (id)obj
{
    if((self = [super init]))
    {
        _obj = obj;
        _queue = dispatch_queue_create("_MABGTimer", NULL);
    }
    return self;
}

- (void)dealloc
{
    if(_timer)
    {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
    }
    dispatch_release(_queue);
    [super dealloc];
}

- (void)_cancel
{
    if(_timer)
    {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = NULL;
    }
}    

- (void)setDelay: (NSTimeInterval)delay block: (void (^)(id))block
{
    [self performBlockOnQueue: ^{
        if(!_timer)
        {
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), 0, 0);
            dispatch_source_set_event_handler(_timer, ^{
                block(_obj);
                [self _cancel];
            });
            dispatch_resume(_timer);
        }
    }];
}

- (void)performBlockOnQueue: (dispatch_block_t)block
{
    dispatch_sync(_queue, block);
}

- (void)cancel
{
    [self performBlockOnQueue: ^{
        [self _cancel];
    }];
}

@end


static NSMutableSet *gStringInternSet;
static NSLock *gLock;

static void Initialize(void)
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        gStringInternSet = [[NSMutableSet alloc] init];
        gLock = [[NSLock alloc] init];
    });
}

static NSString *InternString(NSString *s)
{
    NSString *ret = [gStringInternSet member: s];
    if(!ret)
    {
        // mutable guarantees a unique object
        ret = [NSMutableString stringWithString: s];
        [gStringInternSet addObject: ret];
    }
    return ret;
}

static NSString *FullIdentifier(const char *func, NSString *identifier)
{
    const char *bracket = strchr(func, '[');
    NSCParameterAssert(bracket);
    const char *space = strchr(bracket, ' ');
    NSCParameterAssert(space);
    
    return [NSString stringWithFormat: @"%.*s %@",
            space - bracket - 1, bracket + 1, identifier];
}

static _MABGTimer *GetTimer(id obj, const char *func, NSString *identifier)
{
    Initialize();
    
    [gLock lock];
    
    NSString *fullIdentifier = FullIdentifier(func, identifier);
    NSString *key = InternString(fullIdentifier);
    _MABGTimer *timer = objc_getAssociatedObject(obj, key);
    if(!timer)
    {
        timer = [[_MABGTimer alloc] initWithObject: obj];
        objc_setAssociatedObject(obj, key, timer, OBJC_ASSOCIATION_RETAIN);
        [timer autorelease];
    }
    
    [gLock unlock];
    return timer;
}

void MABGTimerF(id obj, const char *func, NSString *identifier, NSTimeInterval delay, void (^block)(id self))
{
    _MABGTimer *timer = GetTimer(obj, func, identifier);
    [timer setDelay: delay block: block];
}

void MABGTimerLockF(id obj, const char *func, NSString *identifier, void (^block)(void))
{
    _MABGTimer *timer = GetTimer(obj, func, identifier);
    [timer performBlockOnQueue: block];
}

void MABGTimerCancelF(id obj, const char *func, NSString *identifier)
{
    _MABGTimer *timer = GetTimer(obj, func, identifier);
    [timer cancel];
}
