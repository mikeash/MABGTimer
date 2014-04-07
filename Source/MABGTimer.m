//
//  MABGTimer.m
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MABGTimer.h"

#import <mach/mach_time.h>
#import <objc/runtime.h>



@implementation MABGTimer
@synthesize obj = _obj;
@synthesize queue = _queue;

- (id)initWithObject: (id)obj
{
    return [self initWithObject: obj behavior: MABGTimerCoalesce queueLabel: "com.mikeash.MABGTimer"];
}

- (id)initWithObject: (id)obj behavior: (MABGTimerBehavior)behavior queueLabel: (char const *)queueLabel
{
    dispatch_queue_t queue = dispatch_queue_create(queueLabel, NULL);
    return [self initWithObject: obj behavior: behavior queue: queue];
}

- (id)initWithObject: (id)obj behavior: (MABGTimerBehavior)behavior queue: (dispatch_queue_t)queue
{
    if((self = [super init]))
    {
        _obj = obj;
        _behavior = behavior;
        _queue = queue;
        mt_dispatch_retain(_queue);
    }
    return self;
}

- (void)_cancel
{
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        mt_dispatch_release(_timer);
        _timer = NULL;
    }
}    

- (void)_finalize
{
    [self _cancel];
    
    mt_dispatch_release(_queue);
    _queue = nil;
}

- (void)finalize
{
    [self _finalize];
    [super finalize];
}

- (void)dealloc
{
    [self _finalize];
#if !__has_feature(objc_arc) 
    [super dealloc];
#endif
}

- (void)setTargetQueue: (dispatch_queue_t)target
{
    dispatch_set_target_queue(_queue, target);
}

- (NSTimeInterval)_now
{
    return CACurrentMediaTime();
}

- (void)afterDelay: (NSTimeInterval)delay do: (void (^)(id self))block
{
    return [self afterDelay: delay behavior: _behavior do: block];
}

- (void)afterDelay: (NSTimeInterval)delay behavior: (MABGTimerBehavior)behavior do: (void (^)(id self))block
{
    NSTimeInterval requestTime = [self _now];
    
    [self performWhileLocked: ^{

        // adjust delay to take into account time elapsed between the method call and execution of this block
        NSTimeInterval now = [self _now];
        NSTimeInterval adjustedDelay = delay - (now - requestTime);
        if (adjustedDelay < 0.0)
            adjustedDelay = 0.0;

        BOOL hasTimer = _timer != nil;
        
        BOOL shouldProceed = NO;
        if (!hasTimer)
            shouldProceed = YES;
        else if (behavior == MABGTimerDelay)
            shouldProceed = YES;
        else if (behavior == MABGTimerCoalesce && [self _now] + adjustedDelay < _nextFireTime)
            shouldProceed = YES;
        
        if(shouldProceed)
        {
            if (!hasTimer)
                _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, adjustedDelay * NSEC_PER_SEC), 0, 0);
            _nextFireTime = [self _now] + adjustedDelay;
            dispatch_source_set_event_handler(_timer, ^{
                block(_obj);
                [self _cancel];
            });
            if(!hasTimer)
                dispatch_resume(_timer);
        }
    }];
}

- (void)performWhileLocked: (dispatch_block_t)block
{
    if (_queue)
        dispatch_sync(_queue, block);
}

- (void)cancel
{
    [self performWhileLocked: ^{
        [self _cancel];
    }];
}

@end
