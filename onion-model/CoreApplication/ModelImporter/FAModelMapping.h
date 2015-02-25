//
//  FAAPIAdapter.h
//  FestappModel
//
//  Created by Patrick Goley on 11/21/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAModelMapping <NSObject>

/**
 * FAModelMapping is a protocol that defines the interface of an
 * object that can help map external representations of a model 
 * (from a REST API for example) into the appropriate representation
 * for local storage.
 */

#pragma mark - Attributes to External Keys

/**
 *  Get the external key name for a local attribute
 *  from the attributes mapping.
 *
 *  @param attributeName An attribute name.
 *
 *  @return The cooresponding external key for the given attribute.
 */

- (NSString *)externalKeyForAttributeName:(NSString *)attributeName;

/**
 *  Get the external key name for a local relationship
 *  from the relationship mapping.
 *
 *  @param externalKey An relationship name of a local entity
 *                     which cooresponds to a nested object or
 *                     array that represents a relationship.
 *
 *  @return The cooresponding external key name for the relationship.
 */

- (NSString *)externalKeyForRelationshipName:(NSString *)relationshipName;


#pragma mark - External Keys to Attributes

- (NSString *)attributeNameForExternalKey:(NSString *)externalKey;

- (NSString *)relationshipNameForExternalKey:(NSString *)externalKey;

/**
 *  Get a transformed value for an attribute name and a given value. This should be
 *  called for attributes that have a different type locally than in some external
 *  representation, for example converting a date string in JSON to an NSDate. If
 *  no transformer exists for that attribute, the value is returned as is.
 *
 *  @param value A value from some external model representation to be assigned to an attribute
 *  @param attributeName A local attribute name that may need incoming values transformed
 *
 *  @return A transformed value, or the original value if no transformer exists for this attribute
 */

- (id)transformedValueForValue:(id)value attributeName:(NSString *)attributeName;

/**
 *  Creates a sort descriptor for a local query given an external key
 */

- (NSSortDescriptor *)sortDescriptorForExteralKey:(NSString *)externalKey ascending:(BOOL)ascending;

@end
