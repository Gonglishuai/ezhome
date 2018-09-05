//
//  ESReturnGoodsApplyView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ESReturnGoodsApplyViewDelegate <NSObject>

/**
 获取组数

 @return 组数
 */
- (NSInteger)getSectionNums;

/**
 获取每组item数量

 @param section 组索引
 @return 数量
 */
- (NSInteger)getItemsNumsWithSection:(NSInteger)section;

/**
 点击申请退款
 */
- (void)refundBtnTap;

/**
 获取申请退款金额描述

 @return 描述
 */
- (NSString *)getReturnGoodsDescription;

/**
 获取是否仅退款的状态
 */
- (BOOL)getReturnAmountStatus;

@end

@interface ESReturnGoodsApplyView : UIView

@property (nonatomic, weak) id<ESReturnGoodsApplyViewDelegate> delegate;

@property (nonatomic, strong) UITableView *tableView;

- (void)refreshMainView;
- (void)refreshMainViewWithSection:(NSInteger)section;
- (void)refreshMainViewAnimationWithSection:(NSInteger)section;
- (void)refreshMainViewWithSection:(NSInteger)section andIndex:(NSInteger)index;

/**
 使输入项成为第一响应者

 @param index 索引
 */
- (void)setInputFocus:(NSInteger)index;
@end
