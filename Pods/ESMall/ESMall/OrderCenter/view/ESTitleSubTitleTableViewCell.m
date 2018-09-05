//
//  ESTitleSubTitleTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESTitleSubTitleTableViewCell.h"

@interface ESTitleSubTitleTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end

@implementation ESTitleSubTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel.font = [UIFont stec_remarkTextFount];
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle titleColor:(UIColor *)titleColor subTitleColor:(UIColor *)subTitleColor {
    _titleLabel.textColor = titleColor;
    _subTitleLabel.textColor = subTitleColor;
    _subTitleLabel.font = [UIFont stec_remarkTextFount];
    _titleLabel.font = [UIFont stec_remarkTextFount];
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
