//
//  FACoreDataManager+FADefaultManager.m
//  FestappModel
//
//  Created by Patrick Goley on 1/17/15.
//  Copyright (c) 2015 aloompa. All rights reserved.
//

#import "FACoreDataManager+FADefaultManager.h"


@implementation FACoreDataManager (FADefaultManager)

+ (instancetype)defaultManager {
    
    static FACoreDataManager *manager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] initWithModelURL: [self defaultModelURL]
                                        storeURL: [self defaultStoreURL]
                                       storeType: NSSQLiteStoreType];
    });
    
    return manager;
}

+ (NSURL *)defaultModelURL {
    
    NSBundle *modelBundle = [NSBundle mainBundle];
    
    NSURL *modelURL = [modelBundle URLForResource: @"data_model" withExtension: @"momd"];
    
    return modelURL;
}

+ (NSURL *)defaultStoreURL {
    
    NSString *fileName = @"core_data.sqlite";
    
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fullStorePath = [libraryDirectory stringByAppendingPathComponent: fileName]; 
    
    return [NSURL fileURLWithPath: fullStorePath];
}

@end
