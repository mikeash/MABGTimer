//
//  MABGTimer.h
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@import Dispatch;
@import Foundation;

typedef NS_ENUM(NSUInteger, MABGTimerBehavior) {
    /** Subsequent calls with charged timer can only reduce the time until firing, not extend; default value. */MABGTimerCoalesce,
    /** Subsequent calls replace the existing time, potentially extending it. */
    MABGTimerDelay
};

@interface MABGTimer : NSObject

@property (weak) id obj;
@property (readonly, nonnull) dispatch_queue_t queue;

- (nonnull instancetype)initWithObject:(nonnull id)obj;
- (nonnull instancetype)initWithObject:(nonnull id)obj
                              behavior:(MABGTimerBehavior)behavior
                            queueLabel:(char const *_Nonnull)queueLabel;

- (void)setTargetQueue:(nonnull dispatch_queue_t)target;
- (void)afterDelay:(NSTimeInterval)delay do:(void (^_Nonnull)(id _Nonnull self))block;
- (void)performWhileLocked: (void (^_Nonnull)(void))block;
- (void)cancel;

@end
