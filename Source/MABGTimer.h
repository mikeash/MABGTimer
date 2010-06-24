//
//  MABGTimer.h
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MABGTimer : NSObject
{
    id _obj;
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
}

- (id)initWithObject: (id)obj;
- (void)afterDelay: (NSTimeInterval)delay do: (void (^)(id self))block;
- (void)performWhileLocked: (void (^)(void))block;
- (void)cancel;

@end
