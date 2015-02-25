//
//  NSDictionary+TypeSafe.h
//  FestappCore
//
//  Created by Patrick Goley on 11/16/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (FATypeSafe)

- (id)safeObjectForKey:(id)key;

- (id)objectForKey:(id)key ofClass:(Class)class;

- (NSString *)stringForKey:(id)key;

- (NSNumber *)numberForKey:(id)key;

- (BOOL)boolForKey:(id)key;

- (NSDate *)dateForKey:(id)key;

- (NSArray *)arrayForKey:(id)key;

- (NSDictionary *)dictionaryForKey:(id)key;

- (NSDictionary *)plistSafeDictionary;

@end
