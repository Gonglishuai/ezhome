//
//  ESMyGoldHeaderFooterView.m
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyGoldHeaderFooterView.h"

@interface ESMyGoldHeaderFooterView()
@property (weak, nonatomic) IBOutlet UIView *backview;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESMyGoldHeaderFooterView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    
}

- (void)setTitle:(NSString *)title backgroundColor:(UIColor *)backgroundColor {
    _titleLabel.text = title;
    _backview.backgroundColor = backgroundColor;
}


@end
