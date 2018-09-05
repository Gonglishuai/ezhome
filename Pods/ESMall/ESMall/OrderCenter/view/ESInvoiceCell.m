//
//  ESInvoiceCell.m
//  Consumer
//
//  Created by jiang on 2017/7/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceCell.h"

@interface ESInvoiceCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@end

@implementation ESInvoiceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_contentTextColor];
    _titleLabel.font = [UIFont stec_remarkTextFount];
    _subTitleLabel.textColor = [UIColor stec_contentTextColor];
    _subTitleLabel.font = [UIFont stec_remarkTextFount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
}

@end
