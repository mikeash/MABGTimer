//
//  MABGTimer.h
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


void MABGTimerF(id obj, const char *func, NSString *identifier, NSTimeInterval delay, void (^block)(id self));
void MABGTimerLockF(id obj, const char *func, NSString *identifier, void (^block)(void));
void MABGTimerCancelF(id obj, const char *func, NSString *identifier);

#define MABGTimer(identifier, delay, ...) MABGTimerF(self, __func__, identifier, delay, __VA_ARGS__)
#define MABGTimerLock(identifier, ...) MABGTimerLockF(self, __func__, identifier, __VA_ARGS__)
#define MABGTimerCancel(identifier) MABGTimerCancelF(self, __func__, identifier)
