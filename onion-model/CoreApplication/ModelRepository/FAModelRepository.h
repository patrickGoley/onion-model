//
//  FAModelRepository.h
//  FestappModel
//
//  Created by Patrick Goley on 11/14/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocols
#import "FAModelObject.h"

@protocol FAModelRepository <NSObject>


#pragma mark - Initialization

/**
 *  Initialize the repository to access a particular model class.
 *
 *  @param modelClass The class that will be accessed / updated
 *                    by this model repository. Throws if nil.
 *
 *  @return A new model repository
 */

- (instancetype)initWithModelClass:(Class<FAModelObject>)modelClass;

/**
 *  The Class of model objects in this repository.
 */

@property (nonatomic, readonly) Class<FAModelObject> modelClass;

/**
 *  The primary key of the model class
 */
@property (nonatomic, readonly) NSString *primaryKey;


#pragma mark - Insertion

/**
 *  Insert a new record.
 *
 *  @return The inserted record.
 */

- (id<FAModelObject>)insertNew;

/**
 *  Insert a new record with a unique primary key value.
 *
 *  @param idValue The idValue of the new record. Required.
 *
 *  @return The inserted record.
 */

- (id<FAModelObject>)insertWithId:(id)idValue;


#pragma mark - Lookup

/**
 *  Look up a record by id.
 *
 *  @param idNumber The desired id.
 *
 *  @return A record the given id or nil if not found.
 */

- (id<FAModelObject>)objectWithId:(id)idNumber;

/**
 *  Multiple look up with a set of ids.
 *
 *  @param idNumbers The set of unique ids.
 *
 *  @return The array of found records or an empty array.
 */

- (NSArray *)objectsWithIds:(NSSet *)idNumbers;

/**
 *  Get all objects in the repository
 *
 *  @return An array of all objects
 */
- (NSArray *)allObjects;

/**
 *  Basic model querying.
 *
 *  @param predicate       Predicate to filter records by or nil for all records.
 *  @param sortDescriptors Descriptors to sort records by or nil for unsorted records.
 *
 *  @return The array of filtered and sorted records, or an empty array.
 */

- (NSArray *)objectsWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

/**
 *  Basic model counting.
 *
 *  @param predicate       Predicate to filter records by or nil for all records.
 *
 *  @return The count of records matching the predicate.
 */

- (NSUInteger)countForPredicate:(NSPredicate *)predicate;

/**
 *  Check if any objects exists. Uses count queries internally for effeciency.
 *
 *  @return a BOOL denoting if any records exist for this model.
 */

- (BOOL)objectsExist;


#pragma mark - Deletion

/**
 *  Delete an object by id
 *
 *  @param objectId The id of the object to delete.
 */

- (void)deleteObjectWithId:(id)objectId;

/**
 *  Delete an object from the repository.
 *
 *  @param objectToDelete The object to delete.
 */

- (void)deleteObject:(id<FAModelObject>)objectToDelete;

/**
 *  Delete an array of objects.
 *
 *  @param objectsToDelete The array of objects to delete.
 */

- (void)deleteObjects:(NSArray *)objectsToDelete;


#pragma mark - Persisting

/**
 *  Persist all pending changes to an underlying store.
 *
 *  @return A BOOL denoting if the save operation succeeded.
 *          Changes were not saved if NO is returned.
 */

- (BOOL)saveChanges;


#pragma mark - Sibling Repositories

- (instancetype)siblingRepositoryForModelClass:(Class<FAModelObject>)modelClass;

@end
