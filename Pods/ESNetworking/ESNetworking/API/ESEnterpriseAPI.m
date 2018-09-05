
#import "ESEnterpriseAPI.h"
#import "SHHttpRequestManager.h"
#import "JRKeychain.h"
#import "JRNetEnvConfig.h"

@implementation ESEnterpriseAPI

+ (void)getDecorationsSuccess:(void (^) (NSArray *array))success
                      failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.construct;
    NSString *url = [baseUrl stringByAppendingString:@"decoration"];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSArray * returnArray = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:nil];
         if (success)
         {
             success(returnArray);
         }
     } andFailure:failure];
}

+ (void)createEnterpriseWithBody:(NSDictionary *)body
                         success:(void (^) (NSDictionary *dict))success
                         failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.construct;
    NSString *url = [baseUrl stringByAppendingString:@"construct"];
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance]getRequestHeader:nil];
   
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:headerDict
                      withBody:body
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                 NSData * _Nullable responseData)
    {
        NSDictionary * returnDict = [NSJSONSerialization
                                     JSONObjectWithData:responseData
                                     options:NSJSONReadingMutableContainers
                                     error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task,
                   NSError * _Nullable error) {
        if (failure){
            failure(error);
        }
    }];
  
}

+ (void)getConstructListWithOffset:(NSInteger)offset
                             limlt:(NSInteger)limit
                           success:(void (^) (NSDictionary *dict))success
                           failure:(void (^) (NSError *error))failure
{
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.construct;
    NSString *url = [NSString stringWithFormat:
                     @"%@construct/designer/page?designerId=%@&offset=%ld&limit=%ld",
                     baseUrl,
                     jMemberId?:@"",
                     (long)offset,
                     (long)limit];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)getConstructDetailWithPid:(NSString *)projectId
                          success:(void (^) (NSDictionary *dict))success
                          failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.construct;
    NSString *url = [NSString stringWithFormat:
                     @"%@construct/mobile/basicInfo?projectNum=%@",
                     baseUrl,
                     projectId];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)getTransactionListWithOffset:(NSInteger)offset
                               limlt:(NSInteger)limit
                            orderNum:(NSString *)orderNum
                             success:(void (^) (NSArray *array))success
                             failure:(void (^) (NSError *error))failure
{
    if (!orderNum
        || ![orderNum isKindOfClass:[NSString class]])
    {
        orderNum = @"";
    }
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@pay/getOrderPayRecord/%@",baseUrl,orderNum];
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSArray * returnArr = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:NSJSONReadingMutableContainers
                                                                 error:nil];
         if (success)
         {
             success(returnArr);
         }
     } andFailure:failure];
}

@end
