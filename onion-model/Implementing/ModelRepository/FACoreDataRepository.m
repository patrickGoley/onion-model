//
//  FACoreDataRepository.m
//  FestappModel
//
//  Created by Patrick Goley on 10/31/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import "FACoreDataRepository.h"

// Models
#import "BaseModel.h"

// Categories
#import "NSDictionary+FATypeSafe.h"
#import "NSManagedObject+FARelationships.h"


@implementation FACoreDataRepository

@synthesize modelClass = _modelClass;
@synthesize primaryKey = _primaryKey;
@synthesize entity = _entity;

- (instancetype)initWithModelClass:(Class<FAModelObject>)modelClass managedObjectContext:(NSManagedObjectContext *)managedObjectContext {

    NSAssert([(Class)modelClass isSubclassOfClass:[BaseModel class]], @"%@ is not a supported model class. Please subclass BaseModel", modelClass);

    NSParameterAssert(managedObjectContext);
    
    if (self = [super init]) {
        
        _modelClass = modelClass;
        
        _primaryKey = [modelClass primaryKey];
        
        _managedObjectContext = managedObjectContext;
        
        _entity = [NSEntityDescription entityForName:[modelClass entityName]inManagedObjectContext:managedObjectContext];
    }
    
    return self;
}

- (instancetype)initWithModelClass:(Class<FAModelObject>)__unused modelClass {
    
    if (self = [self init]) {
        
        @throw [NSException exceptionWithName: @"FAInvalidInitializerException" reason: @"FACoreDataRepository must be initialized with an NSManagedObjectContext using initWithModelClass:managedObjectContext:" userInfo: nil];
    }
    
    return self;
}

#pragma mark - Creation

- (id<FAModelObject>)insertNew {
    
    return [NSEntityDescription insertNewObjectForEntityForName:self.entity.name inManagedObjectContext:self.managedObjectContext];
}

- (id<FAModelObject>)insertWithId:(id)idValue {
    
    if (!idValue) {
        
        return nil;
    }
    
    BaseModel *newRecord = [NSEntityDescription insertNewObjectForEntityForName:self.entity.name inManagedObjectContext:self.managedObjectContext];
    
    [newRecord setValue: idValue forKey: self.primaryKey];
    
    return newRecord;
}


#pragma mark - Lookup

- (id<FAModelObject>)objectWithId:(id)idNumber {
    
    NSPredicate *primaryIdPredicate = FAEqualToPredicate(self.primaryKey, idNumber);
    
    NSFetchRequest *request = [self fetchRequestWithPredicate: primaryIdPredicate sortDescriptors: nil];
    
    request.fetchLimit = 1;
    
    return [[self.managedObjectContext executeFetchRequest: request error: nil] firstObject];
}

- (NSArray *)objectsWithIds:(NSSet *)idNumbers {
    
    NSPredicate *primaryIdPredicate = FAContainsValueForKeyPredicate(self.primaryKey, idNumbers);
    
    return [self objectsWithPredicate: primaryIdPredicate sortDescriptors: nil];
}

- (NSArray *)objectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    
    NSFetchRequest *request = [self fetchRequestWithPredicate: predicate sortDescriptors: sortDescriptors];
    
    return [self.managedObjectContext executeFetchRequest: request error: nil];
}

- (NSArray *)allObjects {
    
    NSFetchRequest *request = [self fetchRequestWithPredicate:nil sortDescriptors:nil];
    
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}


#pragma mark - Count

- (NSUInteger)countForPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *request = [self fetchRequestWithPredicate: predicate sortDescriptors: nil];
    
    return [self.managedObjectContext countForFetchRequest: request error: nil];
}

- (BOOL)objectsExist {
    
    return [self countForPredicate: nil] > 0;
}


#pragma mark - Deletion

- (void)deleteObjectWithId:(id)objectId {
    
    BaseModel *model = [self objectWithId: objectId];
    
    if (model) {
        
        [self deleteObject: model];
    }
}

- (void)deleteObject:(BaseModel *)objectToDelete {
    
    [objectToDelete.managedObjectContext deleteObject:objectToDelete];
}

- (void)deleteObjects:(NSArray *)objectsToDelete {
    
    for (BaseModel *model in objectsToDelete) {
        
        [self deleteObject: model];
    }
}


#pragma mark - Persisting Changes

- (BOOL)saveChanges {
    
    return [self persistChangesInContext: self.managedObjectContext];
}

- (BOOL)persistChangesInContext:(NSManagedObjectContext *)context {
    
    BOOL success = [self saveChangesInContext: context];
    
    NSManagedObjectContext *parentContext = context.parentContext;
    
    while (parentContext && success) {
        
        success = [self saveChangesInContext: parentContext];
        
        parentContext = parentContext.parentContext;
    }
    
    return success;
}

- (BOOL)saveChangesInContext:(NSManagedObjectContext *)context {
    
    if (![context hasChanges]) {
    
        return YES;
    }
    
    __block NSError *error;
    
    __block BOOL success;
    
    [context performBlockAndWait:^{
        
        success = [context save: &error];
    }];
    
    if (error) {
        
        NSLog(@"\nFailure saving NSManagedObjectContext\nError: \n%@", error);
    }
    
    return success;
}


#pragma mark - Sibling Repositories

- (instancetype)siblingRepositoryForModelClass:(Class<FAModelObject>)modelClass {
    
    return [[[self class] alloc] initWithModelClass: modelClass managedObjectContext: self.managedObjectContext];
}


#pragma mark - CoreData Helpers

- (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:self.entity.name];
    
    request.predicate = predicate;
    
    request.sortDescriptors = sortDescriptors;
    
    return request;
}

#pragma mark - NSObject instance methods

- (NSString *)debugDescription {
    
    return [NSString stringWithFormat:@"%@ - %@", [super debugDescription], NSStringFromClass(self.modelClass)];
}

@end

#pragma mark - Predicate Helper Functions

inline NSPredicate * FAEqualToPredicate(NSString *key, id value) {
    
    return [NSPredicate predicateWithFormat:@"%K = %@", key, value];
}

inline NSPredicate * FANotEqualToPredicate(NSString *key, id value) {
    
    return [NSPredicate predicateWithFormat:@"%K != %@", key, value];
}

inline NSPredicate * FAContainsValueForKeyPredicate(NSString *key, NSSet *set) {
    
    return [NSPredicate predicateWithFormat:@"%K IN %@", key, set];
}

