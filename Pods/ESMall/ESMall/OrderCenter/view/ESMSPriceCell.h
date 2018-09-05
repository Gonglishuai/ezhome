//
//  ESMSPriceCell.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMSPriceCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;


/**
 set data for 共几件商品￥1000

 @param array NSMutableArray
 @param pendDic NSDictionary
 */
- (void)setGoodsNumberAndPrice:(NSMutableArray *)array pendDic:(NSDictionary *)pendDic;



/**
 return goods total price

 @param pendDic NSDictionary
 @return NSString
 */
+ (NSString *)returnTotalPrice:(NSDictionary *)pendDic;

@end
