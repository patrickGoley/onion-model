//
//  FACoreDataRepository+FADefaultRepositories.m
//  FestappModel
//
//  Created by Patrick Goley on 1/10/15.
//  Copyright (c) 2015 aloompa. All rights reserved.
//

#import "FACoreDataRepository+FADefaultRepositories.h"

// Helpers
#import "FACoreDataManager+FADefaultManager.h"

@implementation FACoreDataRepository (FADefaultRepositories)

+ (instancetype)newMainThreadRepositoryForModelClass:(Class)modelClass {
    
    return [[self alloc] initWithModelClass: modelClass
                       managedObjectContext: [[FACoreDataManager defaultManager] mainQueueContext]];
}

+ (instancetype)newPrivateMainThreadRepositoryForModelClass:(Class)modelClass {
    
    return [[self alloc] initWithModelClass: modelClass
                       managedObjectContext: [[FACoreDataManager defaultManager] newMainQueueChildContext]];
}

+ (instancetype)newBackgroundRepositoryForModelClass:(Class)modelClass {
    
    return [[self alloc] initWithModelClass: modelClass
                       managedObjectContext: [[FACoreDataManager defaultManager] privateQueueChildContext]];
}

@end
