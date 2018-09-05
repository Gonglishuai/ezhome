//
//  ESReturnGoodsPriceCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnGoodsPriceCellDelegate <NSObject>

/**
 获取金额title

 @return title
 */
- (NSString *)getReturnGoodsPriceTitle;

/**
 获取金额
 
 @return 金额
 */
- (NSString *)getReturnGoodsPrice;

@end
@interface ESReturnGoodsPriceCell : UITableViewCell

@property (nonatomic, weak) id<ESReturnGoodsPriceCellDelegate> delegate;

- (void)updateCell;
@end
