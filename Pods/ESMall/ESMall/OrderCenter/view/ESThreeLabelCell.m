//
//  ESThreeLabelCell.m
//  Consumer
//
//  Created by jiang on 2017/7/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESThreeLabelCell.h"

@interface ESThreeLabelCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@end

@implementation ESThreeLabelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_contentTextColor];
    _titleLabel.font = [UIFont stec_remarkTextFount];
    _subTitleLabel.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel.font = [UIFont stec_remarkTextFount];
    _priceLabel.textColor = [UIColor stec_contentTextColor];
    _priceLabel.font = [UIFont stec_remarkTextFount];
    _contentLabel.textColor = [UIColor stec_contentTextColor];
    _contentLabel.font = [UIFont stec_remarkTextFount];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle priceTitle:(NSString *)priceTitle contentTitle:(NSString *)contentTitle {
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
    _priceLabel.text = priceTitle;
    _contentLabel.text = contentTitle;
}

@end
