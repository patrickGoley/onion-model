//
//  FACoreDataRepository+FADefaultRepositories.h
//  FestappModel
//
//  Created by Patrick Goley on 1/10/15.
//  Copyright (c) 2015 aloompa. All rights reserved.
//

#import "FACoreDataRepository.h"

@interface FACoreDataRepository (FADefaultRepositories)

+ (instancetype)newMainThreadRepositoryForModelClass:(Class)modelClass;

+ (instancetype)newPrivateMainThreadRepositoryForModelClass:(Class)modelClass;

+ (instancetype)newBackgroundRepositoryForModelClass:(Class)modelClass;

@end
