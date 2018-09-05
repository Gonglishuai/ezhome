//
//  ESAlipayService.m
//  ESFoundation
//
//  Created by jiang on 2017/11/17.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "ESAlipayServices.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DefaultSetting.h"
#import "JRNetEnvConfig.h"

@implementation ESAlipayServices

+ (instancetype)sharedInstance {
    static ESAlipayServices *alipayService = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        alipayService = [[super allocWithZone:NULL]init];
    });
    return alipayService;
}


/**
 处理支付宝客户端程序通过URL启动第三方应用时传递的数据
 
 @param url 启动第三方应用的URL
 */
+ (BOOL)handleOpenURL:(NSURL *)url {
    // 支付跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                              standbyCallback:^(NSDictionary *resultDic) {
                                                  SHLog(@"result = %@",resultDic);
                                              }];
    
    // 授权跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processAuth_V2Result:url
                                     standbyCallback:^(NSDictionary *resultDic) {
                                         SHLog(@"result = %@",resultDic);
                                         NSString *result = resultDic[@"result"];
                                         NSString *authCode = nil;
                                         if (result.length>0) {
                                             NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                                             for (NSString *subResult in resultArr) {
                                                 if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                                                     authCode = [subResult substringFromIndex:10];
                                                     break;
                                                 }
                                             }
                                         }
                                         SHLog(@"授权结果 authCode = %@", authCode?:@"");
                                     }];
    return YES;
}


/**
 支付宝支付
 
 @param payInfo 支付信息（后端返回）
 @param block 支付回调
 */
+ (void)aliPayBackWithModel:(NSString *)payInfo andBlock:(void(^)(NSString *code))block {
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"markplacePay";
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        appScheme = @"esshejijiamall";
    }
    [[AlipaySDK defaultService] auth_V2WithInfo:payInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        NSString *resultStatus = [resultDic objectForKey:@"resultStatus"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:resultStatus forKey:@"resultStatus"];
        [userDefaults synchronize];
        NSLog(@"resultStatus is %@",resultStatus);
        if (block) {
            block(resultStatus);
        }
    }];
}

@end

