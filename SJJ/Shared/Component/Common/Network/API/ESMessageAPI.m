
#import "ESMessageAPI.h"
#import "SHHttpRequestManager.h"

@implementation ESMessageAPI

+ (void)addDeviceWithBody:(NSDictionary *)body
                  success:(void (^) (NSData *data))success
                  failure:(void (^) (NSError *error))failure
{
    if (!body
        || ![body isKindOfClass:[NSDictionary class]])
    {
        if (failure)
        {
            failure(ERROR(@"推送-添加设备", -1000, @"传入的body体为空或者不是字典"));
        }
        return;
    }
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.notification;
    NSString *url = [baseUrl stringByAppendingString:@"device/addDevice"];
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:nil
                      withBody:body
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                 NSData * _Nullable responseData)
    {
         if (success)
         {
             success(responseData);
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task,
                    NSError * _Nullable error) {
         if (failure)
         {
             failure(error);
         }
     }];
}

+ (void)deleteDeviceWithUUID:(NSString *)uuid
                     success:(void (^) (NSData *data))success
                     failure:(void (^) (NSError *error))failure
{
    if (!uuid
        || ![uuid isKindOfClass:[NSString class]])
    {
        if (failure)
        {
            failure(ERROR(@"推送-删除设备", -1000, @"传入的uuid为空或者不是字符串"));
        }
        return;
    }
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.notification;
    NSString *url = [NSString stringWithFormat:@"%@device/clearDeviceMember?uuid=%@", baseUrl, uuid];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
        if (success)
         {
             success(responseData);
         }
     } andFailure:failure];
}

@end
