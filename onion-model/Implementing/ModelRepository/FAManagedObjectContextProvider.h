//
//  FAManagedObjectContextProvider.h
//  FestappModel
//
//  Created by Patrick Goley on 11/17/14.
//  Copyright (c) 2014 aloompa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@protocol FAManagedObjectContextProvider <NSObject>

/*
 * The context to be used for diplaying data in the UI.
 * This context should be treated as a read only context;
 * any changes originating from the UI should be carried out
 * in a context from newMainQueueChildContext.
 */

@property (nonatomic, readonly) NSManagedObjectContext *mainQueueContext;

/*
 * The context to be used for background work such as importing.
 * All work should be done inside a performBlock: or 
 * performBlockAndWait: call to ensure that work is serialized
 * and thread safe. The parentContext of this context is the
 * mainQueueContext.
 */

@property (nonatomic, readonly) NSManagedObjectContext *privateQueueChildContext;

/*
 * A child context to be used on the main thread. This should
 * be used to carry out changes generated from the UI. This allows
 * this changeset to be reset or saved individually back into the
 * mainThreadContext, without interfering with changes occuring
 * elsewhere (i.e. importing).
 */

- (NSManagedObjectContext *)newMainQueueChildContext;

@end
