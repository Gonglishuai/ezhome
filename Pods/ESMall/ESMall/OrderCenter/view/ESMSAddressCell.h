//
//  ESMSAddressCell.h
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESAddress;

@interface ESMSAddressCell : UITableViewCell
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle;


/**
 设置确认订单地址

 @param addressInfo ESAddress
 */
- (void)setMakeSureOrderAdress:(ESAddress *)addressInfo;

@end
