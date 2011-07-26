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

- (id)initWithObject: (id)obj
{
    return [self initWithObject: obj behavior: MABGTimerCoalesce];
}

- (id)initWithObject: (id)obj behavior: (MABGTimerBehavior)behavior
{
    if((self = [super init]))
    {
        _obj = obj;
        _behavior = behavior;
        _queue = dispatch_queue_create("com.mikeash.MABGTimer", NULL);
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

- (void)setTargetQueue: (dispatch_queue_t)target
{
    dispatch_set_target_queue(_queue, target);
}

- (NSTimeInterval)_now
{
    static mach_timebase_info_data_t info;
		static dispatch_once_t pred;
		dispatch_once(&pred, ^{
			mach_timebase_info(&info);
		});
		
		NSTimeInterval t = mach_absolute_time;
		t *= info.numer;
		t /= info.denom;
		return t;
}

- (void)afterDelay: (NSTimeInterval)delay do: (void (^)(id self))block
{
    [self performWhileLocked: ^{
        BOOL hasTimer = _timer != nil;
        
        BOOL shouldProceed = NO;
        if(!hasTimer)
            shouldProceed = YES;
        else if(_behavior == MABGTimerDelay)
            shouldProceed = YES;
        else if(_behavior == MABGTimerCoalesce && [self _now] + delay < _nextFireTime)
            shouldProceed = YES;
        
        if(shouldProceed)
        {
            if(!hasTimer)
                _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
            dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), 0, 0);
            _nextFireTime = [self _now] + delay;
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
    dispatch_sync(_queue, block);
}

- (void)cancel
{
    [self performWhileLocked: ^{
        [self _cancel];
    }];
}

@end
