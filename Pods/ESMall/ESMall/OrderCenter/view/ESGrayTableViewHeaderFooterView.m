//
//  ESGrayTableViewHeaderFooterView.m
//  Consumer
//
//  Created by jiang on 2017/6/28.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESGrayTableViewHeaderFooterView.h"
@interface ESGrayTableViewHeaderFooterView()
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
@implementation ESGrayTableViewHeaderFooterView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _backView.backgroundColor = [UIColor stec_viewBackgroundColor];
}

- (void)setBackViewColor:(UIColor *)backColor {
    _backView.backgroundColor = backColor;
}
@end
