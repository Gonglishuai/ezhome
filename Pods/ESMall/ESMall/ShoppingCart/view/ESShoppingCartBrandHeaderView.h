//
//  ESShoppingCartBrandHeaderView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESShoppingCartBrandHeaderViewDelegate <NSObject>

/**
 品牌是否是已选择状态

 @param section 组索引
 @return YES:品牌为可选状态
 */
- (BOOL)isSelectBrandWithSection:(NSInteger)section;

/**
 获取品牌名字
 
 @param section 组索引
 @return 品牌名
 */
- (NSString *)getBrandNameWithSection:(NSInteger)section;

/**
 选择品牌

 @param section 组索引
 */
- (void)selectBrandWithSection:(NSInteger)section callBack:(void(^)(BOOL successStatus))callback;

/**
 品牌是否是编辑状态

 @param section 组suoyin
 @return YES:为编辑状态
 */
- (BOOL)isEditingWithSection:(NSInteger)section;

/**
 品牌编辑

 @param section 组索引
 @param isEditing 是否是编辑状态
 */
- (void)editBrandWithSection:(NSInteger)section
                  withStatus:(BOOL)isEditing;

/**
 是否是编辑全部状态
 
 @return YES:是 编辑全部 状态
 */
- (BOOL)isEditAllStatus;
@end

@interface ESShoppingCartBrandHeaderView : UITableViewHeaderFooterView
@property (nonatomic, weak) id<ESShoppingCartBrandHeaderViewDelegate> delegate;

- (void)updateHeaderView:(NSInteger)section;
@end
