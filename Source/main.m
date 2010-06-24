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
    [array removeAllObjects];
    NSLog(@"%@", array);
    [array release];
    
    [pool drain];
    
    sleep(1);
    fprintf(stderr, "all done!\n");
    sleep(1000);
    
    return 0;
}

