//
//  ESPayFinanceCollectionViewCell.m
//  ESMall
//
//  Created by jiang on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPayFinanceCollectionViewCell.h"

@interface ESPayFinanceCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *payTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *paySubTitleLabel;
@end

@implementation ESPayFinanceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _payTitleLabel.textColor = [UIColor stec_titleTextColor];
    _payTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    _paySubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _paySubTitleLabel.font = [UIFont stec_tagFount];
    self.layer.borderWidth = 0.5;
}

- (void)setFinanceInfo:(NSDictionary *)dict isSelect:(BOOL)isSelect {
    
    NSString *clientRate = [NSString stringWithFormat:@"%@", dict[@"clientRate"]];
    if ([clientRate isEqualToString:@"0"]) {
        _paySubTitleLabel.text = @"免息优惠";
    } else {
        _paySubTitleLabel.text = [NSString stringWithFormat:@"含服务费%@/期 费率%@%%/月", dict[@"serviceCharge"], dict[@"clientRate"]];
    }
    
    if (isSelect) {
        _payTitleLabel.text = [NSString stringWithFormat:@"✓ %@元 × %@期", dict[@"cost"], dict[@"instalment"]];
        _payTitleLabel.textColor = [UIColor stec_redTextColor];
        _paySubTitleLabel.textColor = [UIColor stec_redTextColor];
        self.layer.borderColor = [[UIColor stec_redTextColor] CGColor];
        self.backgroundColor = [[UIColor stec_redTextColor] colorWithAlphaComponent:0.1];
        
    } else {
        _payTitleLabel.text = [NSString stringWithFormat:@"%@元 × %@期", dict[@"cost"], dict[@"instalment"]];
        _payTitleLabel.textColor = [UIColor stec_subTitleTextColor];
        _paySubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
        self.layer.borderColor = [[UIColor stec_lineBorderColor] CGColor];
        self.backgroundColor = [UIColor whiteColor];

    }
}

@end
