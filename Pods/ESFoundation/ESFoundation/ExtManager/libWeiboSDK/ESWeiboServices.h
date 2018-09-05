//
//  ESWeiboServices.h
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "ESShareView.h"

typedef void(^weiboShareResultBlock)(BOOL isSuccess);

@interface ESWeiboServices : NSObject<WeiboSDKDelegate>

+ (instancetype)sharedInstance;

/**
 注册新浪微博的APPID
 */
- (void)setUpApiKey;

/**
 检查用户是否安装了微博客户端程序
 - returns: 已安装返回YES，未安装返回NO
 */
+ (BOOL)isWeiboAppInstalled;

/**
 处理微博客户端程序通过URL启动第三方应用时传递的数据
 
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 
 - parameter url: 启动第三方应用的URL
 
 - returns: Bool
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 发送分享请求，进行新浪微博分享
 
 - parameter title:   主标题
 - parameter content: 副标题
 - parameter image:   图片
 - parameter urlStr:  分享链接
 */
- (void)sendSinaShareWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                        urlStr:(NSString *)urlStr
                    shareStyle:(ShareStyle)shareStyle
                   resultBlock:(weiboShareResultBlock)resultBlock;
@end
