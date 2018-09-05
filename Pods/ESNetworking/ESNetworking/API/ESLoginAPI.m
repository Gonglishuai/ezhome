//
//  ESLoginAPI.m
//  ESNetworking
//
//  Created by xiefei on 28/6/18.
//  Copyright © 2018年 Easyhome Shejijia. All rights reserved.
//

#import "ESLoginAPI.h"
#import "SHHttpRequestManager.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"
#import "CoStringManager.h"

@implementation ESLoginAPI

///**
// * 获取图形验证码
// */
//+ (void)getIdentifyingCode:(ESSmsCodeType)type
//                andSuccess:(void(^)(NSDictionary *))success
//                andFailure:(void(^)(NSError *error))failure {
//    NSDictionary *headerDict = [self getDefaultHeader];
//    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
//    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v1/sms_codes?";
//    NSString *typeUrl;
//    switch (type) {
//        case ESLogin:
//            typeUrl = @"execute=user.login";
//            break;
//        case ESCreate:
//            typeUrl = @"execute=user.account.create.sms";
//            break;
//        case ESFind:
//            typeUrl = @"execute=user.password.find.sms";
//            break;
//        default:
//            break;
//    }
//
//    NSString *url = [NSString stringWithFormat:@"%@%@%@", baseUrl,apiUrl,typeUrl];
//    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
//        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
//        if (success) {
//            success(returnDict);
//        }
//    } andFailure:failure];
//}'cas-proxy-sign/guest_user_account/api/'v1/image_codes?

+ (void)getIdentifyingImageUrlForLiginWithType:(ESRegisterPageType)type success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [NSString stringWithFormat:@"%@",[JRNetEnvConfig sharedInstance].netEnvModel.host];
    NSString *apiUrl = @"/cas-proxy-sign/guest_user_account/api/v1/image_codes?";
    NSString *typeUrl;
    switch (type) {
        case ESRegisterPageTypeLogin:
            typeUrl = @"execute=user.login";
            break;
        case ESRegisterPageTypeCreate:
            typeUrl = @"execute=user.account.create.sms";
            break;
        case ESRegisterPageTypeFind:
            typeUrl = @"execute=user.password.find.sms";
            break;
        default:
            break;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@%@", baseUrl,apiUrl,typeUrl];
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
    
}

/**
 * 获取图形验证码的url,新服务,目前是注册和,找回密码和绑定手机号用
 */
+ (NSString *)getIdentifyingImageUrlWithType:(ESRegisterPageType)type
                                        UUID:(NSString *)uuid {
    NSString *baseUrl = [NSString stringWithFormat:@"%@/sms",[JRNetEnvConfig sharedInstance].netEnvModel.host];
    NSString *apiUrl = @"/v1/authcode/image?";
    NSString *typeUrl;
    switch (type) {
        case ESRegisterPageTypeBing:
            typeUrl = @"src=binding";
            break;
        case ESRegisterPageTypeCreate:
            typeUrl = @"src=reg";
            break;
        case ESRegisterPageTypeFind:
            typeUrl = @"src=findpwd";
            break;
        default:
            break;
    }
    
    NSString *timeString = [NSString stringWithFormat:@"%.0f", [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970]*1000];
    return [NSString stringWithFormat:@"%@%@%@&uuid=%@&time=%@", baseUrl,apiUrl,typeUrl,uuid,timeString];
}

/**
 * 获取短信验证码
 */
+ (void)getSendSmsCode:(ESSmsCodeType)type
                Mobile:(NSString *)mobileNum
                  UUID:(NSString *)uuid
                  Code:(NSString *)imageCode
            andSuccess:(void(^)(NSDictionary *))success
            andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v2/sms_codes?";
    NSString *typeUrl;
    switch (type) {
        case ESCreate:
            typeUrl = @"execute=user.account.create.sms";
            break;
        case ESFind:
            typeUrl = @"execute=user.password.find.sms";
            break;
        default:
            break;
    }
    NSDictionary *param = @{@"mobile": mobileNum,@"uuid":uuid,@"code":imageCode};
    NSString *url = [NSString stringWithFormat:@"%@%@%@", baseUrl,apiUrl,typeUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 验证短信验证码
 */
+ (void)checkSmsCode:(ESSmsCodeType)type
              Mobile:(NSString *)mobileNum
             smsCode:(NSString *)codeNum
          andSuccess:(void(^)(NSDictionary *))success
          andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v1/sms_codes/validate?";
    NSString *typeUrl;
    switch (type) {
        case ESCreate:
            typeUrl = @"execute=user.account.create.sms";
            break;
        case ESFind:
            typeUrl = @"execute=user.password.find.sms";
            break;
        default:
            break;
    }
    NSDictionary *param = @{@"mobile": mobileNum,@"smsCode": codeNum};
    NSString *url = [NSString stringWithFormat:@"%@%@%@", baseUrl,apiUrl,typeUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 用户注册
 */
+(void)registerUserMobile:(NSString *)mobileNum
                  smsCode:(NSString *)codeNum
        cleartextPassword:(NSString *)password
               andSuccess:(void(^)(NSDictionary *))success
               andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v1/users";
    NSDictionary *param = @{@"mobile": mobileNum,@"smsCode": codeNum,@"cleartextPassword": password};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 用户找回密码
 */
+(void)findPasswordMobile:(NSString *)mobileNum
                  SmsCode:(NSString *)Code
              NewPassword:(NSString *)newPassword
               andSuccess:(void(^)(NSDictionary *))success
               andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v1/users/password";
    NSDictionary *param = @{@"mobile": mobileNum,@"smsCode":Code,@"newPassword":newPassword};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Put:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 游客登录
 */
+(void)loginUserName:(NSString *)account
            password:(NSString *)password
   loginImageCodeKey:(NSString *)imageKey
userLoginImageCodeValue:(NSString *)imageValue
          andSuccess:(void(^)(NSDictionary *))success
          andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v2/login";
    if ([CoStringManager isEmptyString:imageKey]) {
        imageKey = @"";
    }
    if ([CoStringManager isEmptyString:imageValue]) {
        imageValue = @"";
    }
    NSDictionary *param = @{@"userName": account, @"password": password, @"loginImageCodeKey": imageKey,@"userLoginImageCodeValue":imageValue};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:param withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        //        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *returnDict = [ESLoginAPI data:responseData headerFields:((NSHTTPURLResponse *)task.response).allHeaderFields statusCode:((NSHTTPURLResponse *)task.response).statusCode];
        if (success) {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 * 检查手机号是否被注册
 */
+(void)checkPhoneRegisteredUserName:(NSString *)mobileNum
                         andSuccess:(void(^)(NSDictionary *))success
                         andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/guest_user_account/api/v1/users/validate?execute=user.account.validate.has";
    NSDictionary *param = @{@"userName": mobileNum};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 用户获取短信验证码, 绑定手机(发送)
 */
+(void)sendSmsForBindMobile:(NSString *)mobileNum
                 andSuccess:(void(^)(NSDictionary *))success
                 andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/auth_user_account/api/v2/sms_codes?execute=user.mobile.binding.sms";
    NSDictionary *param = @{@"mobile": mobileNum};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 用户验证短信验证码, 绑定手机(验证)
 */
+(void)checkSmsForBindMobile:(NSString *)mobileNum
                     smsCode:(NSString *)codeNum
                  andSuccess:(void(^)(NSDictionary *))success
                  andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"/cas-proxy/auth_user_account/api/v1/sms_codes/validate?execute=user.mobile.binding.sms";
    NSDictionary *param = @{@"mobile": mobileNum,@"smsCode":codeNum};
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Post:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 修改密码
 */
+(void)updatePasswordOldClearTextPassword:(NSString *)oldPassword
                     newClearTextPassword:(NSString *)newPassword
                               andSuccess:(void(^)(NSDictionary *))success
                               andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSString *apiUrl = @"cas-proxy/auth_user_account/api/v1/password";
    NSDictionary *param = @{@"oldClearTextPassword": oldPassword,@"newClearTextPassword":newPassword};
    NSString *url = [NSString stringWithFormat:@"%@/%@", baseUrl,apiUrl];
    [SHHttpRequestManager Put:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 修改用户类型
 */
+(void)changeMemberType:(NSString *)memberType
             andSuccess:(void(^)(NSDictionary *))success
             andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSDictionary *userInfo = [JRKeychain loadAllUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"member-sign/api/v1/userInfo/updateRoleInfo/%@",[userInfo objectForKey:kUserInfoCodeJId]? [userInfo objectForKey:kUserInfoCodeJId] : @""];
    NSDictionary *param = @{@"userType": memberType};
    NSString *url = [NSString stringWithFormat:@"%@/%@", baseUrl,apiUrl];
    [SHHttpRequestManager Put:url withParameters:param withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

/**
 * 获取用户信息
 */
+(void)getMemberInfoAndSuccess:(void(^)(NSDictionary *))success
                    andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.host;
    NSDictionary *userInfo = [JRKeychain loadAllUserInfo];
    NSString *apiUrl = [NSString stringWithFormat:@"gateway-sign/api/v1/member/%@",[userInfo objectForKey:kUserInfoCodeJId]? [userInfo objectForKey:kUserInfoCodeJId] : @""];
    NSString *url = [NSString stringWithFormat:@"%@%@", baseUrl,apiUrl];
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

//获取错误内容中的错误信息 用于展示
+ (NSString *)errMessge:(NSError *)error {
    NSDictionary *dic = error.userInfo;
    NSData *data = dic[@"com.alamofire.serialization.response.error.data"];
    if (data == nil || [data isKindOfClass:[NSNull class]]) {
        return @"服务器开小差了，请稍后再试";
    }
    NSDictionary *errDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (errDic.count == 0 || errDic == nil || [errDic isKindOfClass:[NSNull class]]) {
        return @"请求失败";
    }
    return errDic[@"msg"];
}


#pragma mark - X-Token 赋值
+ (NSDictionary *)data:(NSData *)data headerFields:(NSDictionary *)headerFields statusCode:(NSInteger)statusCode
{
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    
    if (!dict) dict = @{};
    NSMutableDictionary *callBackDict = [dict mutableCopy];
    [callBackDict setObject:@(statusCode) forKey:@"response_status"];
    if (headerFields
        && [headerFields isKindOfClass:[NSDictionary class]]
        && headerFields[@"X-Token"]
        && [headerFields[@"X-Token"] isKindOfClass:[NSString class]])
    {
        [callBackDict setObject:headerFields[@"X-Token"] forKey:@"X-Token"];
    }
    
    return callBackDict;
}
@end
