//
//  ESPersonalCenterConfig.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  个人中心的配置
//

#import <Foundation/Foundation.h>

@interface ESPersonalCenterConfig : NSObject

/**
 *  获取消费者Items
 *  @return 最外层数组为 "组"
 *          内层数组为items    {@"title"   : @"item标题",
 *                            @"icon"    : @"item图标",
 *                            @"action"  : @"item跳转action"}
 */
+ (NSArray <NSArray <NSDictionary *> *> *)getConsumerItemsWithHiddenFinance:(BOOL)hiddenFinance;

/**
 *  获取设计师Items
 *  @return 最外层数组为 "组"
 *          内层数组为items    {@"title"   : @"item标题",
 *                            @"icon"    : @"item图标",
 *                            @"action"  : @"item跳转action"}
 */
+ (NSArray <NSArray <NSDictionary *> *> *)getDesignerItemsWithHiddenFinance:(BOOL)hiddenFinance hasRecommend:(BOOL)hasRecommend;
@end
