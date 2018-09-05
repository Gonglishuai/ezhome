
#import <Foundation/Foundation.h>

@interface ESDeviceUtil : NSObject

+ (void)deleteDeviceCallback:(void (^) (void))cb;

+ (void)addDeviceAndLinked;

+ (NSString *)getUUID;
@end
