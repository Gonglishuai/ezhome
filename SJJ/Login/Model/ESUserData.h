//
//  ESUserData.h
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ESSignInType) {
    ///
    ESSignInTypeDefault,
    ///注册
    ESSignInTypeRegister,
    ///登录，
    ESSignInTypeLoginWitRegister,
    ///其他登录账号
    ESSignInTypeLoginOtherAccount
};

@interface ESUserData : NSObject
///账号
@property (nonatomic,copy)    NSString *account;
///用户昵称
@property (nonatomic,copy)    NSString *userName;
///密码
@property (nonatomic,copy)    NSString *password;


@end
