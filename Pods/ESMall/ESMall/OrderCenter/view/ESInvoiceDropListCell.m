//
//  ESInvoiceDropListCell.m
//  Consumer
//
//  Created by jiang on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceDropListCell.h"

@interface ESInvoiceDropListCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESInvoiceDropListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    self.contentView.backgroundColor = [UIColor stec_viewBackgroundColor];
}

- (void)setTitle:(NSString *)title titleColor:(UIColor *)titleColor {
    if (titleColor) {
        _titleLabel.textColor = titleColor;
        _titleLabel.text = title;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
