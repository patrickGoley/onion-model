//
//  NSArray+FANullSafe.h
//  fa-coreproject-4.0
//
//  Created by Pat Goley on 8/7/14.
//  Copyright (c) 2014 Aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FANullSafe)

- (id)nonNullValuesForKey:(NSString *)key;

- (NSSet *)uniqueNonNullValuesForKey:(NSString *)key;

@end
