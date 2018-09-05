//
//  ESUPAServices.h
//  ESFoundation
//  银联支付
//  Created by jiang on 2017/11/21.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESUPAServices : NSObject

+ (instancetype)sharedInstance;

/**
 *  APP是否已安装检测接口，通过该接口得知用户是否安装银联支付的APP。
 *
 *  @return 返回是否已经安装了银联支付APP
 */
+ (BOOL)isUPAAppInstalled;

/**
 处理银联通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 
 - parameter url: 启动第三方应用的URL
 
 - returns: Bool
 */
+ (void)handleOpenURL:(NSURL *)url;


//银联支付
/* payInfo
 {
 "tn": "upab4ba3c02aa476ea1", 交易流水号
 "schemeStr": "d1e6ecd5993ad2d06a9f50da607c971c",商户自定义协议
 "mode": "",接入模式"00"代表接入生产环境（正式版本需要）；"01"代表接入开发测试环境（测试版本需要）；
 "viewController": "", 发起调用的视图控制器，商户应用程序调用银联手机支付控件的视图控制器
 }
 */
+ (void)upaPayWithPayInfo:(NSString *)orderInfo viewController:(UIViewController *)viewController block:(void(^)(BOOL sucess, NSString *code))block;

@end
