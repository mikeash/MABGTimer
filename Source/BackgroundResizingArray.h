//
//  BackgroundResizingArray.h
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class MABGTimer;

@interface BackgroundResizingArray : NSMutableArray
{
    id *_objs;
    NSUInteger _count;
    NSUInteger _capacity;
    
    MABGTimer *_resizeTimer;
}

@end
