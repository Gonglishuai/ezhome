//
//  PerfectInfoCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "PerfectInfoCell.h"

@interface PerfectInfoCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@end

@implementation PerfectInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor stec_viewBackgroundColor];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    _subTitleLabel.textColor = [UIColor stec_orangeTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle {
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
}
@end
