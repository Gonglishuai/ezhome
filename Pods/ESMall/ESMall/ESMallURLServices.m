//
//  ESMallURLServices.m
//  ESMall
//
//  Created by jiang on 2017/12/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMallURLServices.h"
#import <ESFoundation/ESPublicMethods.h>
#import <ESFoundationURLServices.h>


#import "ESProductDetailViewController.h"
#import "ESSelectListViewController.h"


@implementation ESMallURLServices

+ (void)registerESMallURLServices {
    /**---------------------------子组件的URLServices注册--------------------------**/
    [ESFoundationURLServices registerESFoundationURLServices];
    
    /**---------------------------商城相关--------------------------**/
    
    //商品详情
    [MGJRouter registerURLPattern:@"/Mall/GoodDetail" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------商品详情---------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *flashid = info[@"flashid"]?info[@"flashid"]:@"";
        NSString *activityid = info[@"activityid"]?info[@"activityid"]:@"";
        if (flashid.length>0 && activityid.length>0) {
            ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc] initWithProductId:info[@"goodid"] flashSaleItemId:flashid activityId:activityid];
            productDetailViewCon.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:productDetailViewCon animated:YES];
        } else {
            NSString *designerid = info[@"designerid"] ? info[@"designerid"] : @"";
            ESProductDetailViewController *productDetailViewCon = [[ESProductDetailViewController alloc] initWithProductId:info[@"goodid"] type:ESProductDetailTypeSku designerId:designerid];
            productDetailViewCon.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:productDetailViewCon animated:YES];
        }
    }];
    
    //丽屋超市品类列表
    [MGJRouter registerURLPattern:@"/Mall/LiwuMarketList" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------丽屋超市品类列表----------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        ESSelectListViewController *vc = [[ESSelectListViewController alloc] init];
        [vc setSelectCategoryId:info[@"categoryid"] title:info[@"title"] catalogId:info[@"catalogid"]];
        vc.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    
    
    
}


@end


