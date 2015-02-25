//
//  FAModelImporter.h
//  FestappModel
//
//  Created by Patrick Goley on 12/6/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocols
#import "FAAPIAdapter.h"
#import "FAModelRepository.h"

@protocol FAModelImporter <NSObject>

typedef void(^FAModelBlock)(id<FAModelObject> model);

- (instancetype)initWithModelRepository:(id<FAModelRepository>)modelRepository apiAdpater:(id<FAAPIAdapter>)apiAdpater;

@property (nonatomic, readonly) id<FAModelRepository> modelRepository;

@property (nonatomic, readonly) id<FAAPIAdapter> apiAdapter;

#pragma mark - Model Importing

/**
 *  Insert a record and update it with values from a dictionary.
 *
 *  @param modelDictionary The model dictionary expressing the model.
 *
 *  @return The inserted record, or nil if no primary key was found.
 */

- (void)insertOrUpdateWithModelDictionary:(NSDictionary *)modelDictionary completion:(dispatch_block_t)completion;

/**
 *  Update an existing record with a model representation.
 *
 *  @param modelObject     The object to be updated
 *  @param modelDictionary The model dictionary expressing the model.
 *
 *  @return The inserted record, or nil if no primary key was found.
 */

- (void)updateObject:(id<FAModelObject>)modelObject withModelDictionary:(NSDictionary *)modelDictionary completion:(dispatch_block_t)completion;

/**
 *  Synchronously insert or update a model
 *
 *  @param modelDictionary The model representation
 */

- (id<FAModelObject>)synchronouslyInsertOrUpdateWithModelDictionary:(NSDictionary *)modelDictionary;

/**
 *  Update all records of this model with an array of dictionaries. Any
 *  models matching dictionaries in the array will be updated. Any records
 *  that exist for this model that are NOT expressed in the array of
 *  dictionaries will be DELETED.
 *
 *  @param modelArray An array of model dictionaries.
 */

- (void)updateAllWithModelObjects:(NSArray *)modelObjects completion:(dispatch_block_t)completion;

/**
 *  Update the objects in a relationship of a particular object
 *
 *  @param relationship        The relationship name as expessed in API terms
 *  @param modelRepresentation Either an NSDictionary or NSArray of model representations
 *  @param objectId            The parent object of the relationship being updated
 *  @param completion          A block to be invoked on completion of the importing operation
 */

- (void)updateRelationship:(NSString *)relationship withRepresentation:(id)modelRepresentation sourceModelId:(id)sourceModelId completion:(dispatch_block_t)completion;

@end
