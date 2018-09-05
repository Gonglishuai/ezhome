//
//  ESLoginManager.h
//  Mall
//
//  Created by 焦旭 on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  登录管理类

#import <Foundation/Foundation.h>

@protocol ESLoginManagerDelegate <NSObject>

- (void)onLogin;

- (void)onLogout;

@end

@interface ESLoginManager : NSObject

@property (nonatomic, readonly, assign) BOOL isLogin; //是否为登录状态

+ (instancetype)sharedManager;

- (void)addLoginDelegate:(id<ESLoginManagerDelegate>)delegate;

- (void)removeLoginDelegate:(id<ESLoginManagerDelegate>)delegate;

- (void)login;

/**
 登录完成

 @param dict React Native传回的数据
 */
- (void)loginComplete:(NSDictionary *)dict;

/**
 登出 登出这里只做设计家平台服务的登出，其他第三方服务的登出操作交给上游处理
 */
- (void)logout;
@end
