//
//  ESClickCell.h
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESClickCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subtitleColor;
/**
 set data for 发票
 
 @param indexPath NSIndexPath
 @param invoiceArray invoiceArray
 */
- (void)setInvoiceData:(NSIndexPath*)indexPath invoiceArray:(NSMutableArray *)invoiceArray;


/**
 set data for 优惠券

 @param indexPath NSIndexPath
 @param couponArray NSArray
 */
- (void)setCouponData:(NSIndexPath *)indexPath couponArray:(NSMutableArray *)couponArray;


/**
 set data for 请选择服务门店

 @param indexPath NSIndexPath
 @param selectServerStoreArray NSMutableArray
 */
- (void)setServeShopData:(NSIndexPath *)indexPath selectServerStoreArray:(NSMutableArray *)selectServerStoreArray;



@end
