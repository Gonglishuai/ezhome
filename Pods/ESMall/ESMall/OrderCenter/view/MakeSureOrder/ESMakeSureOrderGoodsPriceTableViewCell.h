//
//  ESMakeSureOrderGoodsPriceTableViewCell.h
//  ESMall
//
//  Created by zhangdekai on 2017/12/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESMakeSureOrderGoodsPriceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *earnestLabel;
@property (weak, nonatomic) IBOutlet UILabel *earnestDeducationLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalPaymentLabel;

/**
 set 双十二定金 data
 
 @param pendDic NSDictionary
 */
- (void)setGoodsPriceMessage:(NSDictionary *)pendDic;

@end
