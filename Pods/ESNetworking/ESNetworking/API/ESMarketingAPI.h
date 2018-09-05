
#import "JRBaseAPI.h"

@interface ESMarketingAPI : JRBaseAPI

+ (void)requestForEnterpriseTipMessage:(void (^) (NSDictionary *dic))success
                               failure:(void (^) (NSError *error))failure;

@end
