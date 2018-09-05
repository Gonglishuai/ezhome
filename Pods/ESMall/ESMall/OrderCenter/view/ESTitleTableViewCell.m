//
//  ESTitleTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/7/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESTitleTableViewCell.h"
@interface ESTitleTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation ESTitleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_contentTextColor];
    _titleLabel.font = [UIFont stec_remarkTextFount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title textColor:(UIColor *)textColor font:(UIFont *)font {
    _titleLabel.text = title;
    _titleLabel.textColor = textColor;
    _titleLabel.font = font;
}

@end
