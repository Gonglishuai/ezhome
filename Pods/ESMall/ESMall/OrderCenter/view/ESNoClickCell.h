//
//  ESNoClickCell.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESNoClickCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subtitleColor;

/**
 设置平台优惠

 @param pendDic NSDictionary
 */
- (void)setDiscountData:(NSDictionary *)pendDic;

/**
 set data for 商家优惠

 @param pendDic NSDictionary
 */
- (void)setShopperDiscount:(NSDictionary *)pendDic;
@end
