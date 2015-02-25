//
//  NSManagedObject+Relationships.h
//  FestappModel
//
//  Created by Patrick Goley on 11/21/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (FARelationships)

- (void)clearObjectsFromRelationship:(NSRelationshipDescription *)relationship;

- (void)addObject:(NSManagedObject *)object toRelationship:(NSRelationshipDescription *)relationship;

@end
