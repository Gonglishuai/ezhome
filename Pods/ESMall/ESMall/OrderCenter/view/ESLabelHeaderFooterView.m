//
//  ESLabelHeaderFooterView.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESLabelHeaderFooterView.h"

@interface ESLabelHeaderFooterView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;


@end

@implementation ESLabelHeaderFooterView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.font = [UIFont stec_titleFount];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
//    _subTitleLabel.textColor = [UIColor stec_titleTextColor];
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
}
- (void)setTitle:(NSString *)title titleColor:(UIColor *)titleColor subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subTitleColor backColor:(UIColor *)backColor {
    _lineLabel.hidden = NO;
    _titleLabel.text = title;
    _titleLabel.textColor = titleColor;
    if (subTitle.length > 0) {
        _subTitleLabel.hidden = NO;
    } else {
        _subTitleLabel.hidden = YES;
    }
    _subTitleLabel.text = subTitle ? subTitle : @"";
    if (subTitleColor) {
        _subTitleLabel.textColor = subTitleColor;
    } else {
        _subTitleLabel.textColor = [UIColor stec_titleTextColor];
    }
    
    _backView.backgroundColor = backColor;
}

@end
