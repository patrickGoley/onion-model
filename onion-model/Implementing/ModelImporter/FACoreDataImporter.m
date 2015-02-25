//
//  FACoreDataImporter.m
//  FestappModel
//
//  Created by Patrick Goley on 12/6/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import "FACoreDataImporter.h"

// Frameworks
@import CoreData;

// Helper Classes
#import "FACoreDataRepository.h"

// Categories
#import "NSDictionary+FATypeSafe.h"
#import "NSManagedObject+FARelationships.h"
#import "NSArray+FANullSafe.h"

// Protocols
#import "FAModelMapping.h"

// Models
#import "BaseModel.h"

@interface FACoreDataImporter ()

@property (nonatomic, strong) FACoreDataRepository *modelRepository;

@property (nonatomic, readonly) id<FAModelMapping> modelMapping;

@property (nonatomic, readonly) NSString *primaryKey;

@end

@implementation FACoreDataImporter

@synthesize apiAdapter = _apiAdapter;

- (instancetype)initWithModelRepository:(id<FAModelRepository>)modelRepository apiAdpater:(id<FAAPIAdapter>)apiAdpater {
    
    if (self = [super init]) {
        
        _modelRepository = modelRepository;
        
        _apiAdapter = apiAdpater;
        
        _modelMapping = [apiAdpater modelMappingForClass: modelRepository.modelClass];
    }
    
    return self;
}


#pragma mark - Insertion

/**
 *  Insert or look up a record by id.
 *
 *  @param idValue The id of the desired record.
 *
 *  @return The found or newly created record with the given id.
 */

- (id)findOrCreateWithWithId:(id)idValue {
    
    BaseModel *record = [self.modelRepository objectWithId: idValue];
    
    if (!record) {
        
        record = [self.modelRepository insertWithId: idValue];
    }
    
    return record;
}


#pragma mark - Updating

/**
 * Create or update a record with a dictionary representation.
 * This method does it's work asynchronously by virtue of
 * performBlock:. The object will be available in the repository
 * when the completion block is invoked.
 *
 * @param modelDictionary A dictionary representation of a model
 */

- (void)insertOrUpdateWithModelDictionary:(NSDictionary *)modelDictionary completion:(dispatch_block_t)completion {
    
    [self.modelRepository.managedObjectContext performBlock:^{
        
        [self internalInsertOrUpdateWithDictionary: modelDictionary];
        
        [self.modelRepository saveChanges];
        
        if (completion) {
            
            completion();
        }
    }];
}

- (id<FAModelObject>)synchronouslyInsertOrUpdateWithModelDictionary:(NSDictionary *)modelDictionary {
    
    __block id<FAModelObject> object;
    
    [self.modelRepository.managedObjectContext performBlockAndWait:^{
        
        object = [self internalInsertOrUpdateWithDictionary: modelDictionary];
        
        [self.modelRepository saveChanges];
    }];
    
    return object;
}

/**
 * This interal call does not use a call to performBlock:
 * so that it can be used within calls to updateWithAllWithArray:
 * and insertOrUpdateWithDictionary:. performBlock: is asynchronous
 * and not re-entrant, so calls to performBlock: cannot be nested.
 * Data will be present in the model repository when this method returns.
 *
 * @param modelDictionary A dictionary representation of a model
 */

- (id<FAModelObject>)internalInsertOrUpdateWithDictionary:(NSDictionary *)modelDictionary {
    
    NSString *externalPrimaryKey = [self externalKeyForAttributeName: self.modelRepository.primaryKey];
    
    NSNumber *idValue = modelDictionary[externalPrimaryKey];
    
    id<FAModelObject> model = [self findOrCreateWithWithId: idValue];
    
    [self updateModel: model withDictionary: modelDictionary timestamp: [NSDate date]];
    
    return model;
}

/**
 * Update all records with an array of model representations.
 * This method does it's work asynchronously by virtue of
 * performBlock:. Thus, it will return immediately to avoid blocking
 * but data will not be immediately available in the model repository.
 *
 *  @param modelArray An array of dictionary model representations.
 */

- (void)updateAllWithModelObjects:(NSArray *)modelObjects completion:(dispatch_block_t)completion {
    
    [self.modelRepository.managedObjectContext performBlock:^{
        
        [self internalUpdateAllWithModelObjects: modelObjects];
        
        if (completion) {
            
            completion();
        }
    }];
}

- (void)internalUpdateAllWithModelObjects:(NSArray *)modelObjects {
    
    NSDate *timestamp = [NSDate date];
    
    // update local records with array
    
    [self updateWithArray: modelObjects timestamp: timestamp eachBlock: nil];
    
    // delete any objects not found in the array
    
    [self deleteObjectsNotUpdatedWithTimestamp: timestamp];
    
    [self.modelRepository saveChanges];
}

/**
 * Create or update multiple records with an array of model representations.
 *
 *  @param modelArray An array of dictionary model representations.
 *
 *  @param timestamp The date to save as the lastUpdated value for updated records.
 *                   
 *  @param eachBlock A block that will be invoked with each inserted or updated record,
 *                   after it's updates have been processed. This can be used to do some
 *                   additional work on each model (such as add to a relationship) without
 *                   have to re-query and re-iterate them.
 */

- (void)updateWithArray:(NSArray *)modelArray timestamp:(NSDate *)timestamp eachBlock:(FAModelBlock)eachBlock {
    
    NSString *primaryKey = self.modelRepository.primaryKey;
    
    NSString *externalPrimaryKey = [self externalKeyForAttributeName: primaryKey];
    
    // get the set of local records matching the id's found in the modelArray
    
    NSSet *idSet = [NSSet setWithArray:[modelArray nonNullValuesForKey: externalPrimaryKey]];
    
    NSArray *localRecords = [self.modelRepository objectsWithIds: idSet];
    
    // store the local records in a dictionary by id for quick look up
    
    NSMutableDictionary *localRecordsById = [NSMutableDictionary dictionaryWithObjects: localRecords
                                                                               forKeys: [localRecords valueForKey: primaryKey]];
    
    // iterate the modelArray, creating or updating local records
    
    for (NSDictionary *modelDict in modelArray) {
        
        NSNumber *idValue = modelDict[externalPrimaryKey];
        
        if (!idValue) {
            
            // didn't find a primary key value in this dictionary
            // skip it!
            
            continue;
        }
        
        BaseModel *localRecord = localRecordsById[idValue];
        
        if (!localRecord) {
            
            // local record with id not found, insert
            
            localRecord = [self.modelRepository insertWithId: idValue];
            
            localRecordsById[idValue] = localRecord;
        }
        
        // apply attribute values and last updated timestamp
        
        [self updateModel: localRecord withDictionary: modelDict timestamp: timestamp];
        
        if (eachBlock && localRecord) {
            
            eachBlock(localRecord);
        }
    }
}

- (void)updateModel:(BaseModel *)model withDictionary:(NSDictionary *)modelDict timestamp:(NSDate *)timestamp {
    
    // update attributes and relationships
    
    [self updateAttributesOfModel: model withDictionary: modelDict];
    
    [self updateRelationshipsOfModel: model withDictionary: modelDict];
    
    // save the last updated timestamp
    
    model.lastUpdated = timestamp;
}

#pragma mark - Updating Attributes

/**
 *  Update the scalar values of a model with a given dictionary.
 *  Only values present in the dictionary will be modified,
 *  and NSNull will clear the value for that attribute.
 *
 *  @param model     the model to be updated
 *  @param modelDict the dictionary representation of the model's
 *                   new state
 */

- (void)updateAttributesOfModel:(BaseModel *)model withDictionary:(NSDictionary *)modelDict {
    
    NSDictionary *attributesByName = [model.entity attributesByName];
    
    [attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *attributeName, NSAttributeDescription *attribute, __unused BOOL *stop) {
        
        if ([attributeName isEqualToString: BaseModelAttributes.lastUpdated]) return;
        
        NSString *externalKey = [self externalKeyForAttributeName: attributeName];
        
        id value = [modelDict objectForKey: externalKey];
        
        if ([value isEqual: [NSNull null]]) {
            
            // the attribute is present in the modelDict but has a null value, set nil for attribute
            
            [model setValue: nil forKey: attributeName];
            
        } else {
            
            // apply any tranformations to the incoming value
            
            id finalValue = [self transformedValueForValue: value
                                             attributeName: attributeName];
            
            Class expectedValueClass = NSClassFromString(attribute.attributeValueClassName);
            
            // for non-transformable type attributes, check that the value's class matches
            // the expected value class
            
            if (attribute.attributeType != NSTransformableAttributeType && ![finalValue isKindOfClass: expectedValueClass]) {
                
                return;
            }
            
            [model setValue: finalValue forKey: attributeName];
        }
    }];
}


#pragma mark - Updating Relationships

- (void)updateRelationship:(NSString *)relationship withRepresentation:(id)modelRepresentation sourceModelId:(id)sourceModelId completion:(dispatch_block_t)completion {
    
#if DEBUG
    
    NSParameterAssert(relationship);
    NSParameterAssert(modelRepresentation);
    NSParameterAssert(sourceModelId);
#endif
    
    [self.modelRepository.managedObjectContext performBlock:^{
        
        id<FAModelObject> sourceObject = [self findOrCreateWithWithId: sourceModelId];
        
        NSString *relationshipName = [self.modelMapping relationshipNameForExternalKey: relationship];
        
        NSDictionary *relationshipsByName = [[self.modelRepository entity] relationshipsByName];
        
        if (relationshipName) {
            
            NSRelationshipDescription *relationshipDescription = relationshipsByName[relationshipName];
            
            if ([relationshipDescription isToMany]) {
                
                NSArray *relatedObjects;
                
                BOOL clearObjects = NO;
                
                if ([modelRepresentation isKindOfClass: [NSArray class]]) {
                    
                    relatedObjects = modelRepresentation;
                    
                    clearObjects = YES;
                    
                } else if ([modelRepresentation isKindOfClass: [NSDictionary class]]) {
                    
                    relatedObjects = @[modelRepresentation];
                }
                
                [self updateToManyRelationship: relationshipDescription
                                   sourceModel: sourceObject
                                     withArray: relatedObjects
                                  clearObjects: clearObjects];
                
            } else {
                
                NSDictionary *relatedObjectDictionary = (NSDictionary *)modelRepresentation;
                
                [self updateToOneRelationship: relationshipDescription
                                  sourceModel: sourceObject
                               withDictionary: relatedObjectDictionary];
            }
            
            [self.modelRepository saveChanges];
        }
        
        if (completion) {
            
            completion();
        }
    }];
}

/**
 *  Update the relationships between the given model
 *  based on nested objects or arrays found in the
 *  modelDict.
 *
 *  @param model     the model to be updated
 *  @param modelDict a dictionary representation of the
 *                   model with nested objects (for to one
 *                   relationships) or arrays (for to many
 *                   relationships) expressing other related
 *                   objects.
 */

- (void)updateRelationshipsOfModel:(BaseModel *)model withDictionary:(NSDictionary *)modelDict {
    
    NSDictionary *relationshipsByName = [model.entity relationshipsByName];
    
    // enumerate the relationship map
    
    [relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipName, NSRelationshipDescription *relationship, __unused BOOL *stop) {
        
        NSString *externalKey = [self externalKeyForRelationshipName: relationshipName];
        
        if ([relationship isToMany]) {
            
            NSArray *nestedArray = [modelDict arrayForKey: externalKey];
            
            if (nestedArray != nil) {
                
                [self updateToManyRelationship: relationship
                                   sourceModel: model
                                     withArray: nestedArray
                                  clearObjects: YES];
            }
            
        } else {
            
            NSDictionary *nestedObject = [modelDict dictionaryForKey: externalKey];
            
            if (nestedObject != nil) {
                
                [self updateToOneRelationship: relationship
                                  sourceModel: model
                               withDictionary: nestedObject];
            }
        }
    }];
}

- (void)updateToOneRelationship:(NSRelationshipDescription *)relationship sourceModel:(BaseModel *)sourceModel withDictionary:(NSDictionary *)objectDict {
    
    if (objectDict && [objectDict isKindOfClass: [NSDictionary class]]) {
        
        FACoreDataImporter *relatedModelImporter = [self importerForRelationship: relationship];
        
        id relatedModel = [relatedModelImporter internalInsertOrUpdateWithDictionary: objectDict];
        
        [sourceModel addObject: relatedModel toRelationship: relationship];
        
    } else {
        
        [sourceModel setValue: nil forKey: relationship.name];
    }
}

- (void)updateToManyRelationship:(NSRelationshipDescription *)relationship sourceModel:(BaseModel *)sourceModel withArray:(NSArray *)relatedObjects clearObjects:(BOOL)clearObjects {
    
    // remove all existing objects in the relationship
    
    if (clearObjects) {
        
        [sourceModel clearObjectsFromRelationship: relationship];
    }
    
    // update the related model with the array,
    // assigning each updated model to the relationship
    
    FACoreDataImporter *relatedModelImporter = [self importerForRelationship: relationship];
    
    [relatedModelImporter updateWithArray: relatedObjects
                                timestamp: [NSDate date]
                                eachBlock:^(BaseModel *relatedModel) {
        
        [sourceModel addObject: relatedModel toRelationship: relationship];
    }];
}

- (instancetype)importerForRelationship:(NSRelationshipDescription *)relationship {
    
    Class relatedModelClass = NSClassFromString([[relationship destinationEntity] managedObjectClassName]);
    
    id<FAModelRepository> relatedModelRepository = [self.modelRepository siblingRepositoryForModelClass: relatedModelClass];
    
    return [[[self class] alloc] initWithModelRepository: relatedModelRepository apiAdpater: self.apiAdapter];
}


#pragma mark - Model Mapping

- (NSString *)externalKeyForAttributeName:(NSString *)attributeName {
    
    return [self.modelMapping externalKeyForAttributeName: attributeName] ?: attributeName;
}

- (NSString *)externalKeyForRelationshipName:(NSString *)relationshipName {
    
    return [self.modelMapping externalKeyForRelationshipName: relationshipName] ?: relationshipName;
}

- (id)transformedValueForValue:(id)value attributeName:(NSString *)attributeName {
    
    if (self.modelMapping) {
        
        return [self.modelMapping transformedValueForValue: value attributeName: attributeName];
        
    } else {
        
        return value;
    }
}


#pragma mark - Deletion

- (void)deleteObjectsNotUpdatedWithTimestamp:(NSDate *)timestamp {
    
    NSPredicate *timestampPredicate = FANotEqualToPredicate(BaseModelAttributes.lastUpdated, timestamp);
    
    NSArray *recordsNotFound = [self.modelRepository objectsWithPredicate: timestampPredicate sortDescriptors: nil];
    
    [self.modelRepository deleteObjects: recordsNotFound];
}

#pragma mark - NSObject instance methods

- (NSString *)debugDescription {
    
    return [NSString stringWithFormat:@"%@ - %@",[super debugDescription], NSStringFromClass(self.modelRepository.modelClass)];
}

@end
