//
//  ESReturnBrandFooterView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnBrandFooterViewDelegate <NSObject>

/**
 获取是否为全选状态

 @return YES:全选状态
 */
- (BOOL)isSelectedAll;

/**
 获取退款金额

 @return 金额
 */
- (NSString *)getTotalPrice;

/**
 点击全选按钮

 @param selectAll 是否选中
 */
- (void)selectAllItems:(BOOL)selectAll;

/**
 是否可选

 @return YES:可点击
 */
- (BOOL)couldSelectAll;

@end

@interface ESReturnBrandFooterView : UITableViewHeaderFooterView

@property (nonatomic, weak) id<ESReturnBrandFooterViewDelegate> delegate;

- (void)updateBrandFooterView;
@end
