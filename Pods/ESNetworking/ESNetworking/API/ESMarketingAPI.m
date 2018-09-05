
#import "ESMarketingAPI.h"
#import "SHHttpRequestManager.h"
#import "JRNetEnvConfig.h"

@implementation ESMarketingAPI

+ (void)requestForEnterpriseTipMessage:(void (^) (NSDictionary *dic))success
                               failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.marketing;
    NSString *url = [baseUrl stringByAppendingString:@"cash/back/surplus/info"];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseData
                                                              options:NSJSONReadingMutableContainers
                                                                error:nil];
         if (success)
         {
             success(dic);
         }
         
     } andFailure:failure];
}

@end
