// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BaseModel.h instead.

#import <CoreData/CoreData.h>

extern const struct BaseModelAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *lastUpdated;
} BaseModelAttributes;

@interface BaseModelID : NSManagedObjectID {}
@end

@interface _BaseModel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) BaseModelID* objectID;

@property (nonatomic, strong) NSNumber* id;

@property (atomic) int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* lastUpdated;

//- (BOOL)validateLastUpdated:(id*)value_ error:(NSError**)error_;

@end

@interface _BaseModel (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;

- (NSDate*)primitiveLastUpdated;
- (void)setPrimitiveLastUpdated:(NSDate*)value;

@end
