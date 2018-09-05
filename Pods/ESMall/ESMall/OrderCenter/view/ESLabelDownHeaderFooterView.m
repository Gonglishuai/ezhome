//
//  ESLabelDownHeaderFooterView.m
//  Consumer
//
//  Created by jiang on 2017/7/20.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESLabelDownHeaderFooterView.h"
#import <ESFoundation/UIFont+Stec.h>
#import <ESFoundation/UIColor+Stec.h>

@interface ESLabelDownHeaderFooterView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation ESLabelDownHeaderFooterView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.font = [UIFont stec_subTitleFount];
    _titleLabel.textColor = [UIColor stec_titleTextColor];

}
- (void)setTitle:(NSString *)title titleColor:(UIColor *)titleColor backColor:(UIColor *)backColor {
    _titleLabel.text = title;
    _titleLabel.textColor = titleColor;

    _backView.backgroundColor = backColor;
}

@end
