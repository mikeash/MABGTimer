//
//  main.m
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "BackgroundResizingArray.h"


int main (int argc, const char * argv[]) {

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
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
    [array release];
    
    sleep(1);
    [pool drain];
    
    fprintf(stderr, "all done!\n");
    sleep(1000);
    
    return 0;
}

