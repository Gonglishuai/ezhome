//
//  ESPersonalCenterConfig.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESPersonalCenterConfig.h"

@implementation ESPersonalCenterConfig

+ (NSArray <NSArray <NSDictionary *> *> *)getConsumerItemsWithHiddenFinance:(BOOL)hiddenFinance {
    
    //第1组：我的优惠券，金币
    NSArray *section0 = @[@{@"title" : @"",
                            @"icon"  : @"",
                            @"action": @""}];
    //第2组：立即预约、我的项目
    NSArray *section1 = @[@{@"title" : @"我的项目",
                            @"icon"  : @"personal_consumer_project",
                            @"action": @"tapMyProject"}];
    
    //第3组：我的钱包
    NSArray *section2 = @[@{@"title" : @"我的钱包",
                            @"icon"  : @"personal_wallet",
                            @"action": @"tapWallet"},
                          @{@"title" : @"居然分期",
                            @"icon"  : @"personal_finance",
                            @"action": @"tapFinance"}];
    
    //第4组：我的订单、我的购物车、收货地址管理
    NSArray *section3 = @[@{@"title" : @"我的订单",
                            @"icon"  : @"personal_order",
                            @"action": @"tapMyOrder"},
                          @{@"title" : @"我的购物车",
                            @"icon"  : @"personal_shopcar",
                            @"action": @"tapShoppingCart"},
                          @{@"title" : @"收货地址管理",
                            @"icon"  : @"personal_address",
                            @"action": @"tapShoppingAddress"}];
    //第5组：设计师推荐
    NSArray *section4 = @[@{@"title" : @"设计师推荐",
                            @"icon"  : @"recommend",
                            @"action": @"tapDesingerRecommend"}];
    
    //第6组：我关注的设计师
    NSArray *section5 = @[@{@"title" : @"我关注的设计师",
                            @"icon"  : @"personal_like",
                            @"action": @"tapMyAttention"},
                          @{@"title" : @"我的评论",
                            @"icon"  : @"personal_my_comment",
                            @"action": @"tapMyCommit"}];
    if (hiddenFinance) {
        NSArray *result = [NSArray arrayWithObjects:section0, section1, section3, section4,section5, nil];
        return result;
    } else {
        NSArray *result = [NSArray arrayWithObjects:section0, section1, section2, section3, section4, section5,nil];
        return result;
    }
    
}

+ (NSArray <NSArray <NSDictionary *> *> *)getDesignerItemsWithHiddenFinance:(BOOL)hiddenFinance hasRecommend:(BOOL)hasRecommend {
    //第1组：我的优惠券，金币
    NSArray *section0 = @[@{@"title" : @"",
                            @"icon"  : @"",
                            @"action": @""}];
    
    //第二组：创建北舒套餐
    NSArray *section1 = @[@{@"title" : @"我的项目",
                            @"icon"  : @"personal_consumer_project",
                            @"action": @"tapDesignerMyProject"},
                          @{@"title" : @"创建项目",
                            @"icon"  : @"personal_scan",
                            @"action": @"tapBeishu"}];
    //第3组：推荐清单
    NSArray *section2 = @[@{@"title" : @"合作品牌",
                            @"icon"  : @"personal_brand",
                            @"action": @"tapCooperativeBrand"},
                          @{@"title" : @"推荐清单",
                            @"icon"  : @"personal_recommend",
                            @"action": @"tapRecommendList"},
                          @{@"title" : @"客户订单",
                            @"icon"  : @"personal_order",
                            @"action": @"tapCustomerOrderList"}];
    //第4组：我的钱包
    NSArray *section3 = @[@{@"title" : @"我的钱包",
                            @"icon"  : @"personal_wallet",
                            @"action": @"tapWallet"},
                          @{@"title" : @"居然分期",
                            @"icon"  : @"personal_finance",
                            @"action": @"tapFinance"}];
    //第二组：创建北舒套餐
    NSArray *section4 = @[@{@"title" : @"我的施工项目",
                            @"icon"  : @"personal_enterprise_project",
                            @"action": @"tapDesignerMyEnterpriseProject"},
                          @{@"title" : @"创建施工项目",
                            @"icon"  : @"personal_enterprise_scan",
                            @"action": @"tapEnterprise"}];
    
    //第6组：我的订单、我的购物车、收货地址管理
    NSArray *section5 = @[@{@"title" : @"我的订单",
                            @"icon"  : @"personal_order",
                            @"action": @"tapMyOrder"},
                          @{@"title" : @"我的购物车",
                            @"icon"  : @"personal_shopcar",
                            @"action": @"tapShoppingCart"},
                          @{@"title" : @"收货地址管理",
                            @"icon"  : @"personal_address",
                            @"action": @"tapShoppingAddress"}];
    
    
    
    //第7组：我关注的设计师
    NSArray *section6 = @[@{@"title" : @"我关注的设计师",
                            @"icon"  : @"personal_like",
                            @"action": @"tapMyAttention"},
                          @{@"title" : @"我的评论",
                            @"icon"  : @"personal_my_comment",
                            @"action": @"tapMyCommit"}];
    if (hiddenFinance) {
        if (hasRecommend) {
            NSArray *result = [NSArray arrayWithObjects:section0, section1, section4, section2, section5, section6, nil];
            return result;
        } else {
            NSArray *result = [NSArray arrayWithObjects:section0, section1, section4, section5, section6, nil];
            return result;
        }
        
    } else {
        if (hasRecommend) {
            NSArray *result = [NSArray arrayWithObjects:section0, section1, section4, section2, section3, section5, section6, nil];
            return result;
        } else {
            NSArray *result = [NSArray arrayWithObjects:section0, section1, section4, section3, section5, section6, nil];
            return result;
        }
        
    }
    
}
@end
