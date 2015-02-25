//
//  FAAdapterProvider.h
//  FestappModel
//
//  Created by Patrick Goley on 11/21/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAModelImporter, FAAPIResource, FAModelMapping, FARESTClient;

@protocol FAAPIAdapter <NSObject>

- (NSArray *)allResourcePaths;

- (id<FAModelMapping>)modelMappingForClass:(Class)modelClass;

- (Class)modelClassForResource:(NSString *)resource; 

@end
