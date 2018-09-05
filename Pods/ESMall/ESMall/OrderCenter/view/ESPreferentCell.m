//
//  ESThreeLabelCell.m
//  Consumer
//
//  Created by jiang on 2017/7/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESPreferentCell.h"
#import "CoStringManager.h"
#import "Masonry.h"

@interface ESPreferentCell()
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;//商品总额
@property (weak, nonatomic) IBOutlet UILabel *totalNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *esPrefrentLabel;//平台优惠
@property (weak, nonatomic) IBOutlet UILabel *esPrefrentNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *proPrefrentLabel;//商家优惠
@property (weak, nonatomic) IBOutlet UILabel *proPrefrentNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponsLabel;//优惠券
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldLabel;//装修基金
@property (weak, nonatomic) IBOutlet UILabel *goldNumLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *earnestLabel;//定金金额
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *earnestNumLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *earnestDiscountLabel;//定金抵扣金额
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *earnestDiscountNumLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *finalPaymentLabel;//尾款金额
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *finalPaymentNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *factPriceLabel;

@end

@implementation ESPreferentCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _totalLabel.textColor = [UIColor stec_subTitleTextColor];
    _totalLabel.font = [UIFont stec_remarkTextFount];
    _totalNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _totalNumLabel.font = [UIFont stec_remarkTextFount];
    
    _esPrefrentLabel.textColor = [UIColor stec_subTitleTextColor];
    _esPrefrentLabel.font = [UIFont stec_remarkTextFount];
    _esPrefrentNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _esPrefrentNumLabel.font = [UIFont stec_remarkTextFount];
    
    _proPrefrentLabel.textColor = [UIColor stec_subTitleTextColor];
    _proPrefrentLabel.font = [UIFont stec_remarkTextFount];
    _proPrefrentNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _proPrefrentNumLabel.font = [UIFont stec_remarkTextFount];
    
    _couponsLabel.textColor = [UIColor stec_subTitleTextColor];
    _couponsLabel.font = [UIFont stec_remarkTextFount];
    _couponNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _couponNumLabel.font = [UIFont stec_remarkTextFount];
    
    _goldLabel.textColor = [UIColor stec_subTitleTextColor];
    _goldLabel.font = [UIFont stec_remarkTextFount];
    _goldNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _goldNumLabel.font = [UIFont stec_remarkTextFount];
    
    _earnestLabel.textColor = [UIColor stec_subTitleTextColor];
    _earnestLabel.font = [UIFont stec_remarkTextFount];
    _earnestNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _earnestNumLabel.font = [UIFont stec_remarkTextFount];
    
    _earnestDiscountLabel.textColor = [UIColor stec_subTitleTextColor];
    _earnestDiscountLabel.font = [UIFont stec_remarkTextFount];
    _earnestDiscountNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _earnestDiscountNumLabel.font = [UIFont stec_remarkTextFount];
    
    _finalPaymentLabel.textColor = [UIColor stec_subTitleTextColor];
    _finalPaymentLabel.font = [UIFont stec_remarkTextFount];
    _finalPaymentNumLabel.textColor = [UIColor stec_subTitleTextColor];
    _finalPaymentNumLabel.font = [UIFont stec_remarkTextFount];
    
    _factPriceLabel.textColor = [UIColor stec_subTitleTextColor];
    _factPriceLabel.font = [UIFont stec_remarkTextFount];
    
}

- (void)setPreferentInfo:(NSDictionary *)orderInfo {
    NSMutableArray *labels = [NSMutableArray array];
    
    double orderpay = [[NSString stringWithFormat:@"%@", ((orderInfo[@"orderAmount"]!= [NSNull null]) ? orderInfo[@"orderAmount"] : @"0.00")] doubleValue];
    
    NSString *orderAccount = @"";
    if (orderpay > 10000000.0) {
        orderAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",orderpay/10000.0]];
    } else {
        orderAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",orderpay]];
    }
    
    
    _totalNumLabel.text =  [NSString stringWithFormat:@"￥%@", orderAccount];
    [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_totalLabel, @"title", _totalNumLabel, @"content", nil]];
    
    //平台优惠
    NSString *promotionAmount = [self getNumbersWithDict:orderInfo andKey:@"promotionAmount"];
    if ([promotionAmount doubleValue] == 0.00) {
        _esPrefrentNumLabel.text = [NSString stringWithFormat:@"无"];
        _esPrefrentLabel.hidden = YES;
        _esPrefrentNumLabel.hidden = YES;
    } else {
        _esPrefrentLabel.hidden = NO;
        _esPrefrentNumLabel.hidden = NO;
        _esPrefrentNumLabel.text = [NSString stringWithFormat:@"-￥%@",promotionAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_esPrefrentLabel, @"title", _esPrefrentNumLabel, @"content", nil]];
    }
    
//    _esPrefrentNumLabel.text = [NSString stringWithFormat:@"-￥%@",[CoStringManager displayCheckPrice:discountAmount]];//([orderInfo objectForKey:@"discountAmount"] ? [orderInfo objectForKey:@"discountAmount"] : @"")];
    
    //商家优惠
    NSString *vendorAmount = [self getNumbersWithDict:orderInfo andKey:@"vendorAmount"];
    if ([vendorAmount doubleValue] == 0.00) {
        _proPrefrentNumLabel.text = [NSString stringWithFormat:@"无"];
        _proPrefrentLabel.hidden = YES;
        _proPrefrentNumLabel.hidden = YES;
    } else {
        _proPrefrentLabel.hidden = NO;
        _proPrefrentNumLabel.hidden = NO;
        _proPrefrentNumLabel.text = [NSString stringWithFormat:@"-￥%@",vendorAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_proPrefrentLabel, @"title", _proPrefrentNumLabel, @"content", nil]];
    }
    
    //([orderInfo objectForKey:@"adjustment"] ? [orderInfo objectForKey:@"adjustment"] : @"0.00")];
    //优惠券
    NSString *couponAmount = [self getNumbersWithDict:orderInfo andKey:@"couponAmount"];
    if ([couponAmount doubleValue] == 0.00) {
        _couponNumLabel.text = [NSString stringWithFormat:@"无"];
        _couponsLabel.hidden = YES;
        _couponNumLabel.hidden = YES;
    } else {
        _couponsLabel.hidden = NO;
        _couponNumLabel.hidden = NO;
        _couponNumLabel.text = [NSString stringWithFormat:@"-￥%@",couponAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_couponsLabel, @"title", _couponNumLabel, @"content", nil]];

    }
    
    //装修基金
    NSString *pointAmount = [self getNumbersWithDict:orderInfo andKey:@"pointAmount"];
    if ([pointAmount doubleValue] == 0.00) {
        _goldNumLabel.text = [NSString stringWithFormat:@"无"];
        _goldLabel.hidden = YES;
        _goldNumLabel.hidden = YES;
    } else {
        _goldLabel.hidden = NO;
        _goldNumLabel.hidden = NO;
        _goldNumLabel.text = [NSString stringWithFormat:@"-￥%@",pointAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_goldLabel, @"title", _goldNumLabel, @"content", nil]];
    }
    
    //定金金额
    NSString *earnestAmount = [self getNumbersWithDict:orderInfo andKey:@"earnestAmount"];
    if ([earnestAmount doubleValue] == 0.00) {
        _earnestNumLabel.text = [NSString stringWithFormat:@"无"];
        _earnestLabel.hidden = YES;
        _earnestNumLabel.hidden = YES;
    } else {
        _earnestLabel.hidden = NO;
        _earnestNumLabel.hidden = NO;
        _earnestNumLabel.text = [NSString stringWithFormat:@"￥%@",earnestAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_earnestLabel, @"title", _earnestNumLabel, @"content", nil]];

    }
    
    //定金抵扣金额
    NSString *earnestDiscountAmount = [self getNumbersWithDict:orderInfo andKey:@"earnestDiscountAmount"];
    if ([earnestDiscountAmount doubleValue] == 0.00) {
        _earnestDiscountNumLabel.text = [NSString stringWithFormat:@"无"];
        _earnestDiscountLabel.hidden = YES;
        _earnestDiscountNumLabel.hidden = YES;
    } else {
        _earnestDiscountNumLabel.hidden = NO;
        _earnestDiscountLabel.hidden = NO;
        _earnestDiscountNumLabel.text = [NSString stringWithFormat:@"￥%@",earnestDiscountAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_earnestDiscountLabel, @"title", _earnestDiscountNumLabel, @"content", nil]];
    }
    
    //尾款金额
    NSString *finalPaymentAmount = [self getNumbersWithDict:orderInfo andKey:@"finalPaymentAmount"];
    if ([finalPaymentAmount doubleValue] == 0.00) {
        _finalPaymentNumLabel.text = [NSString stringWithFormat:@"无"];
        _finalPaymentLabel.hidden = YES;
        _finalPaymentNumLabel.hidden = YES;
    } else {
        _finalPaymentLabel.hidden = NO;
        _finalPaymentNumLabel.hidden = NO;
        _finalPaymentNumLabel.text = [NSString stringWithFormat:@"￥%@",finalPaymentAmount];
        [labels addObject:[NSDictionary dictionaryWithObjectsAndKeys:_finalPaymentLabel, @"title", _finalPaymentNumLabel, @"content", nil]];
    }
    
    double pay = [[NSString stringWithFormat:@"%@", ((orderInfo[@"payAmount"]!= [NSNull null]) ? orderInfo[@"payAmount"] : @"0.00")] doubleValue];
    
    NSString *itemPriceAccount = @"";
    if (pay > 10000000.0) {
        itemPriceAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",pay/10000.0]];
    } else {
        itemPriceAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",pay]];
    }
    
    double paidAmount = [[NSString stringWithFormat:@"%@", ((orderInfo[@"paidAmount"]!= [NSNull null]) ? orderInfo[@"paidAmount"] : @"0.00")] doubleValue];
    
    NSString *paidAmountStr = @"";
    if (paidAmount > 10000000.0) {
        paidAmountStr = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",paidAmount/10000.0]];
    } else {
        paidAmountStr = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",paidAmount]];
    }
    
    NSString *factAccount;
    if (paidAmount > 0) {
        factAccount = [NSString stringWithFormat:@"实付款: ￥%@(已付: ￥%@)",itemPriceAccount, paidAmountStr];
    }else {
        factAccount = [NSString stringWithFormat:@"实付款: ￥%@",itemPriceAccount];
    }
    
    NSMutableAttributedString *factAccountStr = [[NSMutableAttributedString alloc] initWithString:factAccount];
    [factAccountStr addAttribute:NSFontAttributeName value:[UIFont stec_titleFount] range:NSMakeRange(5,itemPriceAccount.length+1)];
    [factAccountStr addAttribute:NSForegroundColorAttributeName value:[UIColor stec_redTextColor] range:NSMakeRange(5,itemPriceAccount.length+1)];
    _factPriceLabel.attributedText = factAccountStr;
    
    [self setConstraints:labels];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setConstraints:(NSArray <NSDictionary *>*)labels {
    @try {
        UILabel *lastLabel = nil;
        for (NSDictionary *labelDict in labels) {
            UILabel *title = [labelDict objectForKey:@"title"];
            UILabel *content = [labelDict objectForKey:@"content"];
            if (lastLabel == nil) {
                [title mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(21));
                    make.top.equalTo(self.contentView.mas_top).with.offset(18);
                    make.leading.equalTo(self.contentView.mas_leading).with.offset(23);
                    make.width.greaterThanOrEqualTo(@(80));
                }];
            }else {
                [title mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(21));
                    make.top.equalTo(lastLabel.mas_bottom);
                    make.leading.equalTo(self.contentView.mas_leading).with.offset(23);
                    make.width.greaterThanOrEqualTo(@(80));
                }];
            }
            lastLabel = title;
            
            [content mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(21));
                make.left.equalTo(title.mas_right);
                make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-23);
                make.centerY.equalTo(title.mas_centerY);
            }];
        }
        
        if (lastLabel != nil) {
            [_factPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView.mas_leading).with.offset(23);
                make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-23);
                make.top.equalTo(lastLabel.mas_bottom).with.offset(8);
                make.height.equalTo(@(21));
                make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-11);
            }];
        }
        [self updateConstraintsIfNeeded];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
    } @finally {
        
    }
       
}

- (NSString *)getNumbersWithDict:(NSDictionary *)dict andKey:(NSString *)key {
    double num = 0;
    if (dict == nil ||
        [dict isKindOfClass:[NSNull class]] ||
        [dict objectForKey:key] == nil ||
        [[dict objectForKey:key] isKindOfClass:[NSNull class]]) {
        num = 0;
    }else {
        @try {
            num = [[dict objectForKey:key] doubleValue];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception.description);
            num = 0;
        }
    }
    
    return [NSString stringWithFormat:@"%.2f", num];
}
@end
