//
//  ESWxServices.h
//  Consumer
//
//  Created by jiang on 2017/10/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "ESShareView.h"

typedef void(^wxShareResultBlock)(BOOL isSuccess);

@interface ESWxServices : NSObject<WXApiDelegate>

+ (instancetype)sharedInstance;

- (void)setUpApiKey;
    
+ (BOOL)isWXAppInstalled;

/**
 处理微信客户端程序通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 
 - parameter url: 启动第三方应用的URL
 
 - returns: Bool
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 发送分享请求，进行微信分享
 
 - parameter title:   主标题
 - parameter content: 副标题
 - parameter image:   图片
 - parameter urlStr:  分享链接
 */
- (void)sendWXShareWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                        urlStr:(NSString *)urlStr
                    shareStyle:(ShareStyle)shareStyle
                  platformType:(PlatformType)platformType
                   resultBlock:(wxShareResultBlock)resultBlock;

//微信支付
/* payInfo
 {
 "appid": "wxb4ba3c02aa476ea1", appid
 "noncestr": "d1e6ecd5993ad2d06a9f50da607c971c",随机编码，为了防止重复的
 "package": "Sign=WXPay",商家根据财付通文档填写的数据和签名
 "partnerid": "10000100", 商家向财付通申请的商家id
 "prepayid": "wx20160218122935e3753eda1f0066087993",预支付订单
 "timestamp": "1455769775",时间戳，防重发
 "sign": "F6DEE4ADD82217782919A1696500AF06"商家根据微信开放平台文档对数据做的签名
 }
 */
- (void)wxPayWithPayInfo:(NSDictionary *)payInfo block:(void(^)(BaseResp *))block;

@end
