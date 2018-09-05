//
//  ESShoppingCartView.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/30.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESShoppingCartViewModel.h"
#import "ESShoppingCartBottomView.h"

@protocol ESShoppingCartViewDelegate <NSObject>

/**
 刷新
 */
- (void)refreshLoadNewData;

/**
 判断该组是否处于编辑状态

 @param section 组索引
 @return YES:处于编辑状态
 */
- (BOOL)isEditingWithSection:(NSInteger)section;


/**
 获取总的组数
 
 @return 组数
 */
- (NSInteger)getSectionNums;


/**
 获取组内item数

 @param section 组索引
 @return item数
 */
- (NSInteger)getItemNumsWithSection:(NSInteger)section;


/**
 获取组的类型

 @param section 组索引
 @return 类型
 */
- (ESCommodityType)getSectionType:(NSInteger)section;

/**
 点击一个条目

 @param section 组索引
 @param index item索引
 */
- (void)tapItemWithSection:(NSInteger)section andIndex:(NSInteger)index;
@end

@interface ESShoppingCartView : UIView

@property (nonatomic, weak) id<ESShoppingCartViewDelegate> delegate;

/// 初始化
- (instancetype)initWithTableBaseVC:(UIViewController *)vc;

//设置底部视图是否可见
- (void)setBottomVisible:(BOOL)visible;

//刷新整个视图
- (void)refreshMainView;

//刷新组
- (void)refreshSections:(NSIndexSet *)indexSet;

//刷新items
- (void)refreshItemsWithIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;

//刷新底部视图
- (void)refreshBottomView;

//设置底部视图右按钮样式
- (void)setBottomRightBtn:(ESCartConfirmButtonType)type;

//滚动到顶部
- (void)scrollToTop;

//删除组
- (void)deleteSectionWithIndexSet:(NSIndexSet *)indexSet;

//删除items
- (void)deleteRowWithIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;
@end
