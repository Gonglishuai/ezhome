//
//  ESNoClickCell.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESNoClickCell.h"
#import <ESFoundation/UIFont+Stec.h>
#import <ESFoundation/UIColor+Stec.h>
#import "CoStringManager.h"

@interface ESNoClickCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation ESNoClickCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = 0;
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    _subTitleLabel.textColor = [UIColor stec_redTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subtitleColor {
    if (subtitleColor) {
        _subTitleLabel.textColor = subtitleColor;
        _titleLabel.text = title;
        _subTitleLabel.text = subTitle;
    }
}

- (void)setDiscountData:(NSDictionary *)pendDic {
    NSString *promotionAmount = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"promotionAmount"]];
    promotionAmount = [CoStringManager displayCheckPrice:promotionAmount];
    NSString *promotionAmountStr = @"";
    if ([promotionAmount isEqualToString:@"0"]) {
        promotionAmountStr = [NSString stringWithFormat:@"无"];
    } else {
        promotionAmountStr = [NSString stringWithFormat:@"-￥%@",promotionAmount];
    }
    [self setTitle:@"平台优惠:" subTitle:promotionAmountStr subTitleColor:[UIColor stec_subTitleTextColor]];
}

- (void)setShopperDiscount:(NSDictionary *)pendDic {
    NSString *vendorAmount = [NSString stringWithFormat:@"%@", [pendDic objectForKey:@"vendorAmount"]];
    vendorAmount = [CoStringManager displayCheckPrice:vendorAmount];
    NSString *vendorAmountStr = @"";
    if ([vendorAmount isEqualToString:@"0"]) {
        vendorAmountStr = [NSString stringWithFormat:@"无"];
    } else {
        vendorAmountStr = [NSString stringWithFormat:@"-￥%@",vendorAmount];
    }
    
    [self setTitle:@"商家优惠:" subTitle:vendorAmountStr subTitleColor:[UIColor stec_subTitleTextColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
