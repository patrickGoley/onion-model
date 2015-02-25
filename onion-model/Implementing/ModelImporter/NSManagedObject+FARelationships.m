//
//  NSManagedObject+Relationships.m
//  FestappModel
//
//  Created by Patrick Goley on 11/21/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import "NSManagedObject+FARelationships.h"

@implementation NSManagedObject (FARelationships)

- (void)clearObjectsFromRelationship:(NSRelationshipDescription *)relationship {
    
    if (relationship.isToMany) {
        
        NSMutableSet *relatedObjects = [self valueForKey: relationship.name];
        
        NSRelationshipDescription *inverseRelationship = relationship.inverseRelationship;
        
        NSManagedObject *relatedObject;
        
        // remove self from related objects relationship
        
        while ((relatedObject = [relatedObjects anyObject])) {
            
            if (inverseRelationship.isToMany) {
                
                [relatedObject removeObject: self fromToManyRelationship: inverseRelationship];
                
            } else {
                
                [relatedObject removeObject: self fromToOneRelationship: inverseRelationship];
            }
        }
        
        // clear all objects from self's relationships
        
        [self setValue: [NSSet set] forKey: relationship.name];
        
    } else {
        
        NSManagedObject *relatedObject = [self valueForKey: relationship.name];
        
        [relatedObject removeObject: self fromToOneRelationship: relationship.inverseRelationship];
        
        [self removeObject: relatedObject fromToOneRelationship: relationship];
    }
}

- (void)removeObject:(NSManagedObject *)object fromToOneRelationship:(NSRelationshipDescription *)relationship {
    
    NSManagedObject *currentRelatedObject = [self valueForKey: relationship.name];
    
    if ([currentRelatedObject isEqual: object]) {
        
        [self setValue: nil forKey: relationship.name];
    }
}

- (void)removeObject:(NSManagedObject *)object fromToManyRelationship:(NSRelationshipDescription *)relationship {
    
    NSMutableSet *relatedObjects = [[self valueForKey: relationship.name] mutableCopy];
    
    if ([relatedObjects containsObject: object]) {
        
        [relatedObjects removeObject: object];
        
        [self setValue: [NSSet setWithSet: relatedObjects] forKey: relationship.name];
    }
}

- (void)addObject:(NSManagedObject *)object toRelationship:(NSRelationshipDescription *)relationship {
    
    if (!object) return;
    
    [self oneWayAddObject: object toRelationship: relationship];
    
    [object oneWayAddObject: self toRelationship: relationship.inverseRelationship];
}

- (void)oneWayAddObject:(NSManagedObject *)object toRelationship:(NSRelationshipDescription *)relationship {
    
    if ([relationship isToMany]) {
        
        id relationshipContainer = [self valueForKey: relationship.name];
        
        NSMutableSet *mutableRelationshipSet;
        
        if ([relationshipContainer isKindOfClass: [NSMutableSet class]]) {
            
            mutableRelationshipSet = (NSMutableSet *)relationshipContainer;
            
        } else if ([relationshipContainer isKindOfClass: [NSSet class]]) {
            
            mutableRelationshipSet = [relationshipContainer mutableCopy];
        }
        
        [mutableRelationshipSet addObject: object];
        
        [self setValue: [NSSet setWithSet: mutableRelationshipSet] forKey: relationship.name];
        
    } else {
        
        [self setValue: object forKey: relationship.name];
    }
}

@end
