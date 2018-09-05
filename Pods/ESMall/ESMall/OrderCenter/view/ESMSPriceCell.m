//
//  ESMSPriceCell.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSPriceCell.h"
@interface ESMSPriceCell()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation ESMSPriceCell

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _numberLabel.textColor = [UIColor stec_titleTextColor];
    _numberLabel.font = [UIFont stec_remarkTextFount];
    _priceLabel.textColor = [UIColor stec_redTextColor];
    _priceLabel.font = [UIFont stec_titleFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    _numberLabel.text = title;
    _priceLabel.text = subTitle;
}

- (void)setGoodsNumberAndPrice:(NSMutableArray *)array pendDic:(NSDictionary *)pendDic {
    
    NSString *itemCount = pendDic[@"itemQuantity"] ? pendDic[@"itemQuantity"] : @"1";
    
    [self setTitle:[NSString stringWithFormat:@"共%@件商品 合计", itemCount] subTitle:[ESMSPriceCell returnTotalPrice:pendDic]];
}

+ (NSString *)returnTotalPrice:(NSDictionary *)pendDic {
    
    double pay = [[NSString stringWithFormat:@"%@", (pendDic[@"payAmount"] ? pendDic[@"payAmount"] : @"0.00")] doubleValue];
    
    NSString *payAccount = @"";
    if (pay > 10000000.0) {
        payAccount = [NSString stringWithFormat:@"￥%@万",[NSString stringWithFormat:@"%.2f",pay/10000.0]];
    } else {
        payAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",pay]];
    }
    
    return payAccount;
}

@end
