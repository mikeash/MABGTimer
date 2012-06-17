//
//  MABGTimer.h
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <Foundation/Foundation.h>

typedef enum
{
    MABGTimerCoalesce, // subsequent calls with charged timer can only reduce the time until firing, not extend; default value
    MABGTimerDelay // subsequent calls replace the existing time, potentially extending it
} MABGTimerBehavior;

@interface MABGTimer : NSObject
{
    __unsafe_unretained id _obj;
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
    MABGTimerBehavior _behavior;
    NSTimeInterval _nextFireTime;
}

@property (assign) id obj;
@property (assign, readonly) dispatch_queue_t queue;

- (id)initWithObject:(id)obj;
- (id)initWithObject:(id)obj behavior: (MABGTimerBehavior)behavior queueLabel:(char const *)queueLabel;

- (void)setTargetQueue: (dispatch_queue_t)target;
- (void)afterDelay: (NSTimeInterval)delay do: (void (^)(id self))block;
- (void)performWhileLocked: (void (^)(void))block;
- (void)cancel;

@end
