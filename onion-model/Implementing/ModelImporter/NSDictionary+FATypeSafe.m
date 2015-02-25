//
//  NSDictionary+TypeSafe.m
//  FestappCore
//
//  Created by Patrick Goley on 11/16/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import "NSDictionary+FATypeSafe.h"

@implementation NSDictionary (FATypeSafe)

- (id)safeObjectForKey:(id)key {
    
    id value = [self objectForKey: key];
    
    if (value == [NSNull null]) {
        
        return nil;
    }
    
    return value;
}

- (NSString *)stringForKey:(id)key {
    
    return [self objectForKey: key ofClass: [NSString class]];
}

- (NSNumber *)numberForKey:(id)key {
    
    return [self objectForKey: key ofClass: [NSNumber class]];
}

- (BOOL)boolForKey:(id)key {
    
    return [[self numberForKey: key] boolValue];
}

- (NSArray *)arrayForKey:(id)key {
    
    return [self objectForKey: key ofClass: [NSArray class]];
}

- (NSDictionary *)dictionaryForKey:(id)key {
    
    return [self objectForKey: key ofClass: [NSDictionary class]];
}

- (NSDate *)dateForKey:(id)key {
    
    return [self objectForKey: key ofClass: [NSDate class]];
}

- (id)objectForKey:(id)key ofClass:(Class)class {
    
    id value = [self  objectForKey: key];
    
    if (![value isKindOfClass: class]) {
        
        return nil;
    }
    
    return value;
}

- (NSDictionary *)plistSafeDictionary {
    
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
        
        if ([obj isKindOfClass: [NSDictionary class]]) {
            
            NSDictionary *subDict = (NSDictionary *)obj;
            
            [mutDict setObject: [subDict plistSafeDictionary] forKey: key];
            
        } else if (![obj isKindOfClass: [NSNull class]]) {
            
            [mutDict setObject: obj forKey: key];
        }
    }];
    
    return [NSDictionary dictionaryWithDictionary:mutDict];
}

@end
