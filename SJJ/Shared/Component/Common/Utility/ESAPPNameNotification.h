//
//  ESAPPNameNotification.h
//  EZHome
//
//  Created by shiyawei on 17/7/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESAPPNameNotification : NSObject

///用户登录/退出 刷新首页
UIKIT_EXTERN NSString *const kHomePageReloadNotification;




///用户账号
UIKIT_EXTERN NSString *const kUserAccount;
///用户密码
UIKIT_EXTERN NSString *const kUserPassword;

@end
