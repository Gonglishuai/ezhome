//
//  ESRecommendOrderHeaderView.m
//  Consumer
//
//  Created by jiang on 2018/1/8.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendOrderHeaderView.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESRecommendOrderHeaderView()

@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;

@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *lineLabel;

@property (strong, nonatomic) void(^myPhoneBlock)(NSString *phoneNum);

@property (copy, nonatomic) NSString *phoneNum;

@end

@implementation ESRecommendOrderHeaderView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.font = [UIFont stec_titleFount];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
    _headerImageView.layer.cornerRadius = _headerImageView.frame.size.height/2;
    
    _nameLabel.font = [UIFont stec_titleFount];
    _nameLabel.textColor = [UIColor stec_subTitleTextColor];
    [_phoneButton setTitleColor:[UIColor stec_blueTextColor] forState:UIControlStateNormal];
    _phoneButton.titleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setAvatar:(NSString *)avatar name:(NSString *)name phone:(NSString *)phone Title:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subTitleColor phoneBlock:(void(^)(NSString *phoneNum))phoneBlock {
    _myPhoneBlock = phoneBlock;
    _lineLabel.hidden = NO;
    _titleLabel.text = title;
    _phoneNum = phone;
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
    if ([avatar hasPrefix:@"http"]) {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"headerDeafult"]];
    } else {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, avatar]] placeholderImage:[UIImage imageNamed:@"headerDeafult"]];
    }
    _nameLabel.text = [NSString stringWithFormat:@"客户姓名：%@", name];
    [_phoneButton setTitle:[NSString stringWithFormat:@"%@", phone] forState:UIControlStateNormal];
}

- (IBAction)phoneButtonClicked:(UIButton *)sender {
    if (_myPhoneBlock && _phoneNum.length>0) {
        _myPhoneBlock(_phoneNum);
    }
}

@end
