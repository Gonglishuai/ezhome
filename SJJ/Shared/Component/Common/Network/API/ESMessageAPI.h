
#import "JRBaseAPI.h"

@interface ESMessageAPI : JRBaseAPI

+ (void)addDeviceWithBody:(NSDictionary *)body
                  success:(void (^) (NSData *data))success
                  failure:(void (^) (NSError *error))failure;

+ (void)deleteDeviceWithUUID:(NSString *)uuid
                     success:(void (^) (NSData *data))success
                     failure:(void (^) (NSError *error))failure;

@end
