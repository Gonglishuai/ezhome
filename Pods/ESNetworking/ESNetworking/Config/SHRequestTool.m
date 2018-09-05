
#import "SHRequestTool.h"
#import "SHAlertView.h"
#import "JRKeychain.h"
#import "ESSignatureUtil.h"
#import <MGJRouter/MGJRouter.h>
#import "AFNetworking.h"
#define OVERDUE_STATUSCODE 401
#define HEADER_TOKEN_KEY @"Authorization"
#define HEADER_X_SIGN @"X-Sign"

@implementation SHRequestTool

/// 网络请求header默认参数
+ (NSDictionary *)defaultHeader
{
    return @{};
}

+ (BOOL)statueIsOverdue:(NSInteger)statusCode
{
    if (statusCode == OVERDUE_STATUSCODE) {
        if ([SHAlertView checkForShowExpiredError]) {
            [SHAlertView saveExpiredErrorStatus];
            [SHAlertView showAlertWithTitle:@"提示" message:@"您的登录已过期" sureKey:^{
                [SHAlertView removeExpiredErrorStatus];
                [MGJRouter openURL:@"/ESFoundation/Logout"];
            }];
        }
        return YES;
    }
    return NO;
}

+ (NSDictionary *)addAuthorizationForHeader:(NSDictionary *)header
{
    NSString *value = [NSString stringWithFormat:@"Basic %@",[JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];
    NSMutableDictionary * headerNew  = [header mutableCopy];
    [headerNew setObject:value forKey:HEADER_TOKEN_KEY];
    header = [headerNew copy];
    NSLog(@"%@",header);
    return header;
}

+ (NSDictionary *)updateHeader:(NSDictionary *)header
                   withRequest:(NSURLRequest *)request
{
    header = [self addDefaultHeader:header];
    header = [self addXSignForHeader:header
                         withRequest:request];
    return header;
}

// 添加默认header
+ (NSDictionary *)addDefaultHeader:(NSDictionary *)header
{
    if (!header
        || ![header isKindOfClass:[NSDictionary class]])
    {
        header = @{};
    }
    
    NSDictionary *defaultHeader = [self defaultHeader];
    
    NSMutableDictionary * headerNew  = [header mutableCopy];
    [defaultHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
     {
         [headerNew setObject:obj forKey:key];
     }];
    
    header = [headerNew copy];
    return header;
}

// 添加签名参数
+ (NSDictionary *)addXSignForHeader:(NSDictionary *)header
                        withRequest:(NSURLRequest *)request
{
    if (!header
        || ![header isKindOfClass:[NSDictionary class]])
    {
        header = @{};
    }
    
    NSString *value = [ESSignatureUtil getXSignValueWithRequest:request];
    NSMutableDictionary * headerNew  = [header mutableCopy];
    [headerNew setObject:value forKey:HEADER_X_SIGN];
    header = [headerNew copy];
    return header;
}

/**
 网络请求返回错误信息
 
 @param error NSError
 @return NSString
 */
+ (NSString *)getErrorMessage:(NSError *)error {
    NSString *msg = @"网络错误, 请稍后重试!";
    @try {
        NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSError *err = nil;
        NSDictionary * errorDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        if (err == nil && errorDict && [errorDict objectForKey:@"msg"]) {
            msg = [errorDict objectForKey:@"msg"];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
    } @finally {
        return msg;
    }
}

@end
