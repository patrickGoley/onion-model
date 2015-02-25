//
//  FACoreDataManager.m
//  FestappModel
//
//  Created by Patrick Goley on 10/31/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import "FACoreDataManager.h"

@interface FACoreDataManager ()

@property (nonatomic, strong, readonly) NSURL *modelURL;

@property (nonatomic, strong, readonly) NSURL *storeURL;

@property (nonatomic, strong, readonly) NSString *storeType;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation FACoreDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainQueueContext = _mainQueueContext;
@synthesize privateQueueChildContext = _privateQueueChildContext;


- (instancetype)initWithModelURL:(NSURL *)modelURL storeURL:(NSURL *)storeURL storeType:(NSString *)storeType {
    
    if (self = [super init]) {
        
        _modelURL = modelURL;
        
        _storeURL = storeURL;
        
        _storeType = storeType;
    }
    
    return self;
}


#pragma mark - NSManagedObjectContext

- (NSManagedObjectContext *)mainQueueContext {
    
    if (!_mainQueueContext) {
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        
        context.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        _mainQueueContext = context;
    }
    
    return _mainQueueContext;
}

- (NSManagedObjectContext *)privateQueueChildContext {
    
    if (!_privateQueueChildContext) {
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSPrivateQueueConcurrencyType];
        
        context.parentContext = self.mainQueueContext;
        
        _privateQueueChildContext = context;
    }
    
    return _privateQueueChildContext;
}

- (NSManagedObjectContext *)newMainQueueChildContext {
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    
    context.parentContext = self.mainQueueContext;
    
    return context;
}


#pragma mark - NSPersistentStoreCoordinator

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (!_persistentStoreCoordinator) {
        
        NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL: self.modelURL];
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
        
        NSError *error;
        
        NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES};
        
        [_persistentStoreCoordinator addPersistentStoreWithType: self.storeType
                                                  configuration: nil
                                                            URL: self.storeURL
                                                        options: options
                                                          error: &error];
        
        if (error) {
            
            NSLog(@"\n\nError creating Core Data persistent store\n\n");
        }
    }
    
    return _persistentStoreCoordinator;
}

@end
