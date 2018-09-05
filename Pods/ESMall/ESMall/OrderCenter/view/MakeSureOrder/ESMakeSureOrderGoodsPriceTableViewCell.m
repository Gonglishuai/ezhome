//
//  ESMakeSureOrderGoodsPriceTableViewCell.m
//  ESMall
//
//  Created by zhangdekai on 2017/12/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMakeSureOrderGoodsPriceTableViewCell.h"
#import "ESMSPriceCell.h"

@implementation ESMakeSureOrderGoodsPriceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = 0;
}

- (void)setGoodsPriceMessage:(NSDictionary *)pendDic {
    
    _totalPriceLabel.text = [ESMSPriceCell returnTotalPrice:pendDic];
    
    NSNumber *earnestAmount = pendDic[@"earnestAmount"] ? pendDic[@"earnestAmount"] : @0.00;
    
    _earnestLabel.text = [NSString stringWithFormat:@"￥%.2f",[earnestAmount doubleValue]];

    NSNumber *discount = pendDic[@"earnestDiscountAmount"] ? pendDic[@"earnestDiscountAmount"] : @0.00;
    
    NSString *earnestDiscountAmount = [NSString stringWithFormat:@"￥%.2f",[discount doubleValue]] ;
    _earnestDeducationLabel.text = earnestDiscountAmount;

    NSNumber *final = pendDic[@"finalPayment"] ? pendDic[@"finalPayment"] : @0.00;
    NSString *finalPayment = [NSString stringWithFormat:@"￥%.2f",[final doubleValue]] ;
    _finalPaymentLabel.text = finalPayment;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
