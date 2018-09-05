//
//  ESOrderDetailTabbar.h
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESOrderTabbarBtnType)//订单详情底部按钮type
{
    ESOrderTabbarBtnTypeDefault = 0,//无意义
    ESOrderTabbarBtnTypeCancel,//取消订单
    ESOrderTabbarBtnTypePay,//去支付
    ESOrderTabbarBtnTypeDrawback,//申请退款
    ESOrderTabbarBtnTypeGetPage,//确认收货
    ESOrderTabbarBtnTypeGetServer//确认服务
    
};

@interface ESOrderDetailTabbar : UIView
+ (instancetype)creatWithFrame:(CGRect)frame Info:(NSDictionary *)info block:(void(^)(ESOrderTabbarBtnType))block;
- (void)setOrderInfo:(NSDictionary *)orderInfo;
@end
