//
//  ESOrderStatusCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESOrderStatusCellDelegate <NSObject>

/**
 获取状态栏背景图

 @return 背景图
 */
- (NSString *)getStatusBackImg;

/**
 获取状态名称

 @return 名称
 */
- (NSString *)getStatusTitle;

/**
 获取状态栏详细信息

 @return 详细信息
 */
- (NSString *)getStatusDetail;

/**
 获取状态栏扩展信息

 @return 扩展信息
 */
- (NSString *)getStatusExtend;

@end

@interface ESOrderStatusCell : UITableViewCell
@property (nonatomic, weak) id<ESOrderStatusCellDelegate> delegate;

- (void)updateStatusCell;
@end
