#import "BaseModel.h"

@interface BaseModel ()

// Private interface goes here.

@end

@implementation BaseModel

+ (NSString *)entityName {
    
    return NSStringFromClass(self);
}

+ (NSString *)primaryKey {
    
    return BaseModelAttributes.id;
}

- (id)idValue {
    
    return self.id;
}

@end
