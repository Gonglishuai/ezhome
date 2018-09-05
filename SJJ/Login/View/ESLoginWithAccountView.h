//
//  ESLoginWithAccountView.h
//  Homestyler
//
//  Created by shiyawei on 29/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BottomBtnClickBlock)();

@interface ESLoginWithAccountView : UIView

@property (nonatomic,copy)    BottomBtnClickBlock bottomBtnClickBlock;
///登录密码
@property (nonatomic,copy)    NSString *passwordText;
///图形验证码
@property (nonatomic,copy)    NSString *captcha;
///
@property (nonatomic,copy)    NSString *loginImageCodeKey;
///
@property (nonatomic,copy)    NSString *userLoginImageCodeValue;

///添加图片验证码输入框
- (void)addCaptcha;

@end
