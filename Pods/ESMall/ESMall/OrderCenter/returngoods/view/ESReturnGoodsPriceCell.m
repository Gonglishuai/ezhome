//
//  ESReturnGoodsPriceCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsPriceCell.h"

@implementation ESReturnGoodsPriceCell
{
    __weak IBOutlet UILabel *_priceTitleLabel;
    __weak IBOutlet UILabel *_priceLabel;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCell {
    if ([self.delegate respondsToSelector:@selector(getReturnGoodsPriceTitle)]) {
        _priceTitleLabel.text = [self.delegate getReturnGoodsPriceTitle];
    }
    if ([self.delegate respondsToSelector:@selector(getReturnGoodsPrice)]) {
        _priceLabel.text = [self.delegate getReturnGoodsPrice];
    }
}

@end
