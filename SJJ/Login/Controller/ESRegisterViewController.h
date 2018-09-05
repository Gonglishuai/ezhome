//
//  ESRegisterViewController.h
//  Homestyler
//
//  Created by shiyawei on 26/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESBaseViewController.h"
#import "ESUserData.h"
#import "ESLoginAPI.h"




@interface ESRegisterViewController : ESBaseViewController
//@property (nonatomic,assign)    ESSignInType signInType;
@property (nonatomic,copy)    NSString *titleName;
@property (nonatomic,assign)    ESRegisterPageType pageType;
@end
