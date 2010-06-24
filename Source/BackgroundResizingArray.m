//
//  BackgroundResizingArray.m
//  BackgroundTimer
//
//  Created by Michael Ash on 6/23/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import "BackgroundResizingArray.h"

#import "MABGTimer.h"


@implementation BackgroundResizingArray

- (void)dealloc
{
    [self removeAllObjects];
    
    MABGTimerCancel(@"resize");
    free(_objs);
    [super dealloc];
}

- (void)_realloc: (NSUInteger)howmuch
{
    _capacity = howmuch;
    _objs = realloc(_objs, _capacity * sizeof(*_objs));
}

- (void)_ensureSpace: (NSUInteger)amount
{
    if(amount > _capacity)
        [self _realloc: MAX(_capacity * 2, 16)];
}

- (void)_resize
{
    NSLog(@"Resizing! %llu %llu", (unsigned long long)_capacity, (unsigned long long)_count);
    if(_capacity > _count)
        [self _realloc: _count];
}

- (NSUInteger)count
{
    return _count;
}

- (id)objectAtIndex: (NSUInteger)index
{
    if(index < _count)
    {
        __block id ret;
        MABGTimerLock(@"resize", ^{
            ret = [_objs[index] retain];
        });
        return [ret autorelease];
    }
    else
        [NSException raise: NSRangeException format: @"Index %llu is beyond end of array %llu", (unsigned long long)index, (unsigned long long)_count];
    return nil;
}

- (void)addObject: (id)anObject
{
    [self insertObject: anObject atIndex: _count];
}

- (void)insertObject: (id)anObject atIndex: (NSUInteger)index
{
    if(index > _count)
        [NSException raise: NSRangeException format: @"Index %llu is beyond end of array %llu", (unsigned long long)index, (unsigned long long)_count];
    
    MABGTimerLock(@"resize", ^{
        [self _ensureSpace: _count + 1];
        memmove(_objs + index + 1, _objs + index, (_count - index) * sizeof(*_objs));
        _objs[index] = [anObject retain];
    });
    _count++;
}

- (void)removeLastObject
{
    if(_count)
        [self removeObjectAtIndex: _count - 1];
}

- (void)removeObjectAtIndex: (NSUInteger)index
{
    if(index >= _count)
        [NSException raise: NSRangeException format: @"Index %llu is beyond end of array %llu", (unsigned long long)index, (unsigned long long)_count];
    
    MABGTimerLock(@"resize", ^{
        [_objs[index] release];
        _objs[index] = nil;
        memmove(_objs + index, _objs + index + 1, (_count - index) * sizeof(*_objs));
    });
    _count--;
    
    MABGTimer(@"resize", 0.5, ^(id self) {
        [self _resize];
    });
}

- (void)replaceObjectAtIndex: (NSUInteger)index withObject: (id)anObject
{
    if(index >= _count)
        [NSException raise: NSRangeException format: @"Index %llu is beyond end of array %llu", (unsigned long long)index, (unsigned long long)_count];
    MABGTimerLock(@"resize", ^{
        [_objs[index] release];
        _objs[index] = [anObject retain];
    });
}

@end
