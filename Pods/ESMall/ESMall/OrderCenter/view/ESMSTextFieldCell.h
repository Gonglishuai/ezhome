//
//  ESMSTextFieldCell.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMSTextFieldCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder arrowHidden:(BOOL)arrowHidden block:(void(^)(NSString*))block;

- (void)setKeyboardBlock:(void(^)(CGRect inSuperViewFrame))block;


/**
 设置配送时间

 @param updateDic NSDictionary
 @param indexPath NSIndexPath
 */
- (void)setDeliveryTime:(NSMutableDictionary *)updateDic indexPath:(NSIndexPath *)indexPath;



/**
 return buyer leave message

 @param indexPath NSIndexPath
 @param updateDic NSDictionary
 @return NSString
 */
- (NSString *)returnBuyerMessage:(NSIndexPath *)indexPath updateDic:(NSMutableDictionary *)updateDic;

@end
