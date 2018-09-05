//
//  ESGetNoteCodeController.h
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//获取短信验证码，校验短信验证码

#import "ESBaseViewController.h"
#import "ESLoginAPI.h"

@interface ESGetNoteCodeController : ESBaseViewController
///注册手机号
@property (nonatomic,copy)    NSString *phoneNumber;
@property (nonatomic,assign)    ESRegisterPageType pageType;
@end
