//
//  ESSetPasswordController.h
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//
//设置密码/重置密码
#import "ESBaseViewController.h"

#import "ESLoginAPI.h"

@interface ESSetPasswordController : ESBaseViewController
@property (nonatomic,copy)    NSString *phone;
@property (nonatomic,copy)    NSString *msgCode;
@property (nonatomic,assign)    ESRegisterPageType pageType;
@end
