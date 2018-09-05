//
//  ESUPAServices.m
//  ESFoundation
//
//  Created by jiang on 2017/11/21.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "ESUPAServices.h"
#import "UPPaymentControl.h"
#import <ESNetworking/JRNetEnvModel.h>
#import "JRNetEnvConfig.h"

typedef void(^UPAPayResutBlock)(BOOL sucess, NSString *message);

@interface ESUPAServices()

@property (nonatomic,copy)   UPAPayResutBlock resultBlock;

@end

static NSString *const ESUPASchemeIdentityForConsumer = @"upapay82c5a1b3c7a6eedd";

static NSString *const ESUPASchemeIdentityForMall = @"upapayea4a589dc9c0dad6";

@implementation ESUPAServices

+ (instancetype)sharedInstance {
    static ESUPAServices *ESUPAServices = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        ESUPAServices = [[super allocWithZone:NULL]init];
    });
    
    return ESUPAServices;
}


+ (BOOL)isUPAAppInstalled {
    BOOL installed = [[UPPaymentControl defaultControl] isPaymentAppInstalled];
    return installed;
}

/**
 处理银联通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 
 - parameter url: 启动第三方应用的URL
 
 - returns: Bool
 */
+ (void)handleOpenURL:(NSURL *)url {
    [[UPPaymentControl defaultControl]handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        NSLog(@"银联支付 code:%@  data:%@",code,data);
        if([ESUPAServices sharedInstance].resultBlock) {
            NSString *payResoult;
            BOOL paySucess = NO;
            if([code isEqualToString:@"success"]) {
                payResoult = @"支付成功";
                paySucess = YES;
            } else if([code isEqualToString:@"fail"]) {
                payResoult = @"支付失败!";
            } else if([code isEqualToString:@"cancel"]) {
                payResoult = @"该订单支付取消!";
            } else {
                payResoult = [NSString stringWithFormat:@"支付失败! retstr = %@", code];
            }
            [ESUPAServices sharedInstance].resultBlock(paySucess,payResoult);
        }
    }];
}

/**
 银联支付
 @param orderInfo 订单信息
 @param viewController UIViewController
 */
+ (void)upaPayWithPayInfo:(NSString *)orderInfo viewController:(UIViewController *)viewController block:(void(^)(BOOL sucess, NSString *message))block {
    
    if(orderInfo != nil && orderInfo.length > 0) {
        if(block) {
            [ESUPAServices sharedInstance].resultBlock = block;
        }
        NSString *appScheme = [JRNetEnvConfig sharedInstance].netEnvModel.schemeForUPAPay;
        
        [[UPPaymentControl defaultControl]startPay:orderInfo fromScheme:appScheme mode:@"00" viewController:viewController];
    }
}

@end
