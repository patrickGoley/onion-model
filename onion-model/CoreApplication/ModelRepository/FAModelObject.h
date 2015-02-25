//
//  FAModelObject.h
//  FestappModel
//
//  Created by Patrick Goley on 11/15/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAModelObject <NSObject>

+ (NSString *)entityName;

+ (NSString *)primaryKey;

- (id)idValue;

@end
