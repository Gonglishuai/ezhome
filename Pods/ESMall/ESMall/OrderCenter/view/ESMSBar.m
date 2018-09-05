//
//  ESMSBar.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSBar.h"

@interface ESMSBar ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (strong, nonatomic) void(^myblock)(void);
@property (strong, nonatomic) NSMutableDictionary *info;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *allLabelTopConstraint;

@end

@implementation ESMSBar

- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _discountLabel.textColor = [UIColor stec_titleTextColor];
    _discountLabel.font = [UIFont stec_headerFount];
    _priceLabel.textColor = [UIColor stec_redTextColor];
    _priceLabel.font = [UIFont stec_bigTitleFount];
    _discountPriceLabel.textColor = [UIColor stec_redTextColor];
    _discountPriceLabel.font = [UIFont stec_headerFount];
    
    [_updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _updateButton.backgroundColor = [UIColor stec_ableButtonBackColor];
    _updateButton.titleLabel.font = [UIFont stec_bigTitleFount];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _updateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

+ (instancetype)creatWithFrame:(CGRect)frame Info:(NSDictionary *)info block:(void(^)(void))block {
    ESMSBar *orderTabbar = [[ESMallAssets hostBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    orderTabbar.frame = frame;
    orderTabbar.myblock = block;
    return orderTabbar;
}

- (void)setOrderInfo:(NSDictionary *)info isCustom:(BOOL)isCustom {
    
    double pay = [[NSString stringWithFormat:@"%@", (info[@"payAmount"] ? info[@"payAmount"] : @"0.00")] doubleValue];
    self.priceLabel.text = [self getPriceStr:pay];
    
    double payDiscount = [[NSString stringWithFormat:@"%@", (info[@"discountAmount"] ? info[@"discountAmount"] : @"0.00")] doubleValue];
    if (payDiscount <= 0)
    {
        _allLabelTopConstraint.constant = CGRectGetHeight(self.frame)/2.0 - CGRectGetHeight(_titleLabel.frame)/2.0f;
        _discountLabel.hidden = YES;
        _discountPriceLabel.hidden = YES;
    }
    else
    {
        _allLabelTopConstraint.constant = 10.0f;
        _discountLabel.hidden = NO;
        _discountPriceLabel.hidden = NO;
        NSString *payDiscountStr = [self getPriceStr:payDiscount];
        payDiscountStr = [@"-" stringByAppendingString:payDiscountStr];
        self.discountPriceLabel.text = payDiscountStr;
    }

    if (isCustom) {
        _titleLabel.text = @"定金:";
    } else {
        _titleLabel.text = @"合计:";
    }
}

- (NSString *)getPriceStr:(double)price
{
    NSString *amount = @"";
    if (price > 10000000.0) {
        amount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",price/10000.0]];
    } else {
        amount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",price]];
    }
    
    amount = [NSString stringWithFormat:@"￥%@",amount];
    return amount;
}

- (IBAction)updateButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
