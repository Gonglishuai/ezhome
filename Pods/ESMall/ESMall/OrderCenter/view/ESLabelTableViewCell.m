//
//  ESLabelTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESLabelTableViewCell.h"

@interface ESLabelTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end

@implementation ESLabelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subtitleColor {
    if (subtitleColor) {
        _subTitleLabel.textColor = subtitleColor;
        _titleLabel.text = title;
        _subTitleLabel.text = subTitle;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
