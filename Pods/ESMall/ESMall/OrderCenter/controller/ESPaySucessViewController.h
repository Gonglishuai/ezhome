//
//  ESPaySucessViewController.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"

typedef NS_ENUM(NSInteger, ESPaySucessType)
{
    ESPaySucessTypeDefault,
    ESPaySucessTypeEnterprise,
    ESPaySucessTypePkgProjectList,
    ESPaySucessTypePkgProjectDetail
};

@interface ESPaySucessViewController : MPBaseViewController

@property (nonatomic, assign) ESPaySucessType type;

- (void)setOrderId:(NSString *)orderId money:(NSString *)money;

@end
