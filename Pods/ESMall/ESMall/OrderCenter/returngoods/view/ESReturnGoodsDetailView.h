//
//  ESReturnGoodsDetailView.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESOrderStatusCell.h"           //状态栏
#import "ESReturnGoodsPriceCell.h"      //实退金额
#import "ESOrderDescriptionCell.h"      //拒绝原因
#import "ESTitleTableViewCell.h"        //品牌
#import "ESReturnGoodsItemCell.h"       //商品信息
#import "ESClickCell.h"                 //联系商家
#import "ESReturnGoodsOrderInfoCell.h"  //订单信息

@protocol ESReturnGoodsDetailViewDelegate <NSObject>

/**
 获取组数

 @return 组数
 */
- (NSInteger)getSectionNums;


/**
 获取条目数

 @param section 组索引
 @return 条目数
 */
- (NSInteger)getItemsNums:(NSInteger)section;

/**
 获取对应的cell

 @param tableView tableView
 @param indexPath indexPath
 @return 对应的cell
 */
- (__kindof UITableViewCell *)getCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;


/**
 点击了某行cell

 @param className 对应cell的类名
 */
- (void)didSelectCellWithCellClass:(NSString *)className;

/**
 点击确认退款按钮
 */
- (void)confirmReturnTap;

/**
 获取来源
 
 @return 是否来自推荐
 */
- (BOOL)getFromRecommend;

@end

@interface ESReturnGoodsDetailView : UIView

@property (nonatomic, weak) id<ESReturnGoodsDetailViewDelegate> delegate;

- (void)refreshMainView;

- (void)showBottomView:(BOOL)show;
@end
