//
//  ESCaseHeaderView.m
//  Consumer
//
//  Created by jiang on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseHeaderView.h"

@interface ESCaseHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property(strong, nonatomic) void(^myBlock)(void);

@end

@implementation ESCaseHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.backgroundColor = [UIColor whiteColor];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_bigTitleFount];
    _subtitleLabel.font = [UIFont stec_remarkTextFount];
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
}
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subImgName:(NSString *)imgName subTitleColor:(UIColor *)subTitleColor  tapBlock:(void(^)(void))tapBlock {
    _titleLabel.text = title;
    _subtitleLabel.textColor = subTitleColor;
    _subtitleLabel.text = subTitle;
    _iconImageView.image = [UIImage imageNamed:imgName];
    
    _myBlock = tapBlock;
}
- (IBAction)buttonClicked:(UIButton *)sender {
    if (_myBlock) {
        _myBlock();
    }
}

@end
