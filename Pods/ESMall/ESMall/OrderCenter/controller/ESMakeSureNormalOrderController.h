//
//  ESMakeSureNormalOrderController.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"
typedef NS_ENUM(NSUInteger, ESMakeSureOrderType) {
    ESMakeSureOrderTypeNormal,          //普通
    ESMakeSureOrderTypeDoubleTwelve,    //双十二
};

/**普通确认订单页*/
@interface ESMakeSureNormalOrderController : MPBaseViewController//
- (void)setDataSource:(NSDictionary *)dict;

- (instancetype)initViewControllerWithType:(ESMakeSureOrderType)orderType;

@end
