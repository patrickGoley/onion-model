//
//  FACoreDataManager.h
//  FestappModel
//
//  Created by Patrick Goley on 10/31/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAManagedObjectContextProvider.h"

@import CoreData;

// FACoreDataManager takes care of setting up a Core Data stack
// and providing NSManagedObjectContexts to clients of the stack

@interface FACoreDataManager : NSObject <FAManagedObjectContextProvider>

- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL storeType:(NSString *)storeType;

@end
