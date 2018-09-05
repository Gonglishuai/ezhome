//
//  ESLoginAPI.h
//  ESNetworking
//
//  Created by xiefei on 28/6/18.
//  Copyright © 2018年 Easyhome Shejijia. All rights reserved.
//

#import "JRBaseAPI.h"
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ESCreate = 0,
    ESFind,
} ESSmsCodeType;

//typedef enum : NSUInteger {
//    ESUserBing = 0,
//    ESUserCreate,
//    ESUserFind
//} ESImageCodeType;

typedef NS_ENUM(NSUInteger,ESRegisterPageType) {
    ///注册
    ESRegisterPageTypeCreate,
    ///找回密码
    ESRegisterPageTypeFind,
    ///绑定手机号
    ESRegisterPageTypeBing,
    ///登录页的图谱按验证码
    ESRegisterPageTypeLogin
};

@interface ESLoginAPI : JRBaseAPI

///**
// * 获取图形验证码的url
// */
//+ (void)getIdentifyingCode:(ESSmsCodeType)type
//                andSuccess:(void(^)(NSDictionary *))success
//                andFailure:(void(^)(NSError *error))failure;



/**
 获取验证码 -- 登录 多次登录错误使用
 
 @param type ESRegisterPageType
 @param success success
 @param failure failure
 */
+ (void)getIdentifyingImageUrlForLiginWithType:(ESRegisterPageType)type success:(void(^)(NSDictionary *))success failure:(void(^)(NSError *error))failure;

/**
 * 获取图形验证码的url,新服务,目前是注册和,找回密码和绑定手机号用
 */
+ (NSString *)getIdentifyingImageUrlWithType:(ESRegisterPageType)type
                                        UUID:(NSString *)uuid;

/**
 * 获取短信验证码
 */
+ (void)getSendSmsCode:(ESSmsCodeType)type
                Mobile:(NSString *)mobileNum
                  UUID:(NSString *)uuid
                  Code:(NSString *)imageCode
            andSuccess:(void(^)(NSDictionary *))success
            andFailure:(void(^)(NSError *error))failure;

/**
 * 验证短信验证码
 */
+ (void)checkSmsCode:(ESSmsCodeType)type
              Mobile:(NSString *)mobileNum
             smsCode:(NSString *)codeNum
          andSuccess:(void(^)(NSDictionary *))success
          andFailure:(void(^)(NSError *error))failure;

/**
 * 用户注册
 */
+(void)registerUserMobile:(NSString *)mobileNum
                  smsCode:(NSString *)codeNum
        cleartextPassword:(NSString *)password
               andSuccess:(void(^)(NSDictionary *))success
               andFailure:(void(^)(NSError *error))failure;

/**
 * 用户找回密码
 */
+(void)findPasswordMobile:(NSString *)mobileNum
                  SmsCode:(NSString *)Code
              NewPassword:(NSString *)newPassword
               andSuccess:(void(^)(NSDictionary *))success
               andFailure:(void(^)(NSError *error))failure;

/**
 * 游客登录
 */
+(void)loginUserName:(NSString *)account
            password:(NSString *)password
   loginImageCodeKey:(NSString *)imageKey
userLoginImageCodeValue:(NSString *)imageValue
          andSuccess:(void(^)(NSDictionary *))success
          andFailure:(void(^)(NSError *error))failure;

/**
 * 检查手机号是否被注册
 */
+(void)checkPhoneRegisteredUserName:(NSString *)mobileNum
                         andSuccess:(void(^)(NSDictionary *))success
                         andFailure:(void(^)(NSError *error))failure;

/**
 * 用户获取短信验证码, 登录状态绑定手机用(发送)
 */
+(void)sendSmsForBindMobile:(NSString *)mobileNum
                 andSuccess:(void(^)(NSDictionary *))success
                 andFailure:(void(^)(NSError *error))failure;

/**
 * 用户验证短信验证码, 绑定手机(验证)
 */
+(void)checkSmsForBindMobile:(NSString *)mobileNum
                     smsCode:(NSString *)codeNum
                  andSuccess:(void(^)(NSDictionary *))success
                  andFailure:(void(^)(NSError *error))failure;

/**
 * 修改密码
 */
+(void)updatePasswordOldClearTextPassword:(NSString *)oldPassword
                     newClearTextPassword:(NSString *)newPassword
                               andSuccess:(void(^)(NSDictionary *))success
                               andFailure:(void(^)(NSError *error))failure;

/**
 * 修改用户类型
 */
+(void)changeMemberType:(NSString *)memberType
             andSuccess:(void(^)(NSDictionary *))success
             andFailure:(void(^)(NSError *error))failure;

/**
 * 获取用户信息
 */
+(void)getMemberInfoAndSuccess:(void(^)(NSDictionary *))success
                    andFailure:(void(^)(NSError *error))failure;

/**
 处理错误信息
 
 @param error 接口返回的错误
 @return error中的错误信息
 */
+ (NSString *)errMessge:(NSError *)error;

@end
