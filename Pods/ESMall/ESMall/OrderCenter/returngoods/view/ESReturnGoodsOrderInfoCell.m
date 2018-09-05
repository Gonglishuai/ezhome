//
//  ESReturnGoodsOrderInfoCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsOrderInfoCell.h"

@implementation ESReturnGoodsOrderInfoCell
{
    __weak IBOutlet UILabel *_orderIdLabel;
    __weak IBOutlet UILabel *_orderCreateTimeLabel;
    __weak IBOutlet UILabel *_orderReturnAmountLabel;
    __weak IBOutlet UILabel *_orderReturnReasonLabel;
    __weak IBOutlet UILabel *_serviceStoreLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateOrderInfoCell {
    if ([self.delegate respondsToSelector:@selector(getOrderNo)]) {
        _orderIdLabel.text = [self.delegate getOrderNo];
    }
    if ([self.delegate respondsToSelector:@selector(getOrderCreateTime)]) {
        _orderCreateTimeLabel.text = [self.delegate getOrderCreateTime];
    }
    if ([self.delegate respondsToSelector:@selector(getOrderReturnAmount)]) {
        _orderReturnAmountLabel.text = [self.delegate getOrderReturnAmount];
    }
    if ([self.delegate respondsToSelector:@selector(getOrderReturnReason)]) {
        _orderReturnReasonLabel.text = [self.delegate getOrderReturnReason];
    }
    if ([self.delegate respondsToSelector:@selector(getServiceStore)]) {
        _serviceStoreLabel.text = [self.delegate getServiceStore];
    }
}

@end
