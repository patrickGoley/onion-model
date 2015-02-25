//
//  NSArray+FANullSafe.m
//  fa-coreproject-4.0
//
//  Created by Pat Goley on 8/7/14.
//  Copyright (c) 2014 Aloompa. All rights reserved.
//

#import "NSArray+FANullSafe.h"

@implementation NSArray (FANullSafe)

- (id)nonNullValuesForKey:(NSString *)key {
    
    return [[self valueForKey:key] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat: @"SELF != %@", [NSNull null]]];
}

- (NSSet *)uniqueNonNullValuesForKey:(NSString *)key {
    
    return [NSSet setWithArray:[self nonNullValuesForKey:key]];
}

@end
