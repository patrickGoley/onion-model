 //
//  FACoreDataRepository.h
//  FestappModel
//
//  Created by Patrick Goley on 10/31/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FAModelRepository.h"

@import CoreData;

@interface FACoreDataRepository : NSObject <FAModelRepository>

- (instancetype)initWithModelClass:(Class)modelClass managedObjectContext:(NSManagedObjectContext *)managedObjectContext NS_DESIGNATED_INITIALIZER;

- (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, readonly) NSEntityDescription *entity;

@end

extern NSPredicate * FAEqualToPredicate(NSString *key, id value);

extern NSPredicate * FANotEqualToPredicate(NSString *key, id value);

extern NSPredicate * FAContainsValueForKeyPredicate(NSString *key, NSSet *set);