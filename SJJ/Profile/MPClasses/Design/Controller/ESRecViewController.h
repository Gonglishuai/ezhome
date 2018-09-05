//
//  ESRecViewController.h
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//
//推荐分享--填写用户信息
#import <UIKit/UIKit.h>
#import "MPBaseViewController.h"
#import "ESCaseShareModel.h"

@interface ESRecViewController : MPBaseViewController
@property (nonatomic,strong)    ESCaseShareModel *sharedModel;
///资源类型 10:3D案例 20:商品清单 30:品牌清单 ,
@property (nonatomic,strong)    NSNumber *sourceType;
///清单id 
@property (nonatomic,strong)    NSNumber *baseId;
@end
