//
//  ESRecommentProductTableViewCell.m
//  Consumer
//
//  Created by jiang on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommentProductTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESRecommentProductTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeReasonLabel;

@end

@implementation ESRecommentProductTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _productNameLabel.font = [UIFont stec_titleFount];
    _productNameLabel.textColor = [UIColor stec_titleTextColor];
    
    _productPriceLabel.font = [UIFont stec_bigTitleFount];
    _productPriceLabel.textColor = [UIColor stec_redTextColor];
    
    _describeReasonLabel.font = [UIFont stec_titleFount];
    _describeReasonLabel.textColor = [UIColor stec_contentTextColor];
    
}

- (void)setInfo:(NSDictionary *)info {
    NSString *imageUrl = [NSString stringWithFormat:@"%@", info[@"image"] ? info[@"image"] : @""];
    if ([imageUrl hasPrefix:@"http"]) {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imageUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    _productNameLabel.text = [NSString stringWithFormat:@"%@", info[@"name"] ? info[@"name"] : @""];
    _productPriceLabel.text = [NSString stringWithFormat:@"￥%@", info[@"price"] ? info[@"price"] : @"0.00"];
    _describeReasonLabel.text = [NSString stringWithFormat:@"%@", info[@"description"] ? info[@"description"] : @""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
