//
//  main.m
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BackgroundResizingArray.h"
#import "MABGTimer.h"


int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    MABGTimer *timer = [[MABGTimer alloc] initWithObject: nil];
    id block = ^{ NSLog(@"coalesced!"); };
    [timer afterDelay: 1000 do: block];
    [timer afterDelay: 0.1 do: block];
    sleep(1);
    
    NSMutableArray *array = [[BackgroundResizingArray alloc] init];
    [array addObject: @"one"];
    [array addObject: @"two"];
    [array addObject: @"three"];
    NSLog(@"%@", array);
    [array removeObjectAtIndex: 1];
    NSLog(@"%@", array);
    for(int i = 0; i < 100000; i++)
        [array addObject: [NSString stringWithFormat: @"%d", i]];
    for(int i = 0; i < 1000000; i++)
    {
        if(random() % 2 == 0)
            [array addObject: [NSString stringWithFormat: @"%d", i]];
        else
            [array removeLastObject];
    }
    [array removeAllObjects];
    NSLog(@"%@", array);
    
    NSLog(@"sleeping");
    sleep(2);
    [array release];
    NSLog(@"all done!");
    [pool drain];
    
    sleep(1000);
    
    return 0;
}

