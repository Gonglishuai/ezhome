//
//  ESAlipayServices.h
//  ESFoundation
//
//  Created by jiang on 2017/11/17.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESAlipayServices : NSObject
+ (instancetype)sharedInstance;

/**
 处理支付宝客户端程序通过URL启动第三方应用时传递的数据

 @param url 启动第三方应用的URL
 */
+ (BOOL)handleOpenURL:(NSURL *)url;

/**
 支付宝支付
 
 @param payInfo 支付信息（后端返回）
 @param block 支付回调
 */
+ (void)aliPayBackWithModel:(NSString *)payInfo andBlock:(void(^)(NSString *code))block;
@end
