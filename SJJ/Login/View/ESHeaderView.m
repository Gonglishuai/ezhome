//
//  ESHeaderView.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESHeaderView.h"

#import "Masonry.h"


@interface ESHeaderView ()
@property (nonatomic,strong)    UIImageView *headerImgView;
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *subLabel;
@end


@implementation ESHeaderView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor stec_whiteTextColor];
    }
    return self;
}

- (void)setSignInType:(ESSignInType)signInType {
    _signInType = signInType;
    [self createUIView];
}

#pragma mark --- private method

- (void)createUIView {

    [self addSubview:self.headerImgView];
    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.centerX.equalTo(self);
        make.height.mas_offset(60);
        make.width.mas_offset(60);
    }];
    
    [self addSubview:self.subLabel];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImgView.mas_bottom).offset(10);
        make.height.mas_offset(30);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
}
#pragma mark --- private method
- (NSString *)resetAccountNumber:(NSString *)account {
    if (account == nil) {
        return @"登录";
    }else {
        NSMutableString *mStr = [[NSMutableString alloc] initWithString:account];
        [mStr replaceCharactersInRange:NSMakeRange(3,4) withString:@"****"];
        return mStr;
    }
}

#pragma mark --- 懒加载
- (UIImageView *)headerImgView {
    if (!_headerImgView) {
        _headerImgView = [[UIImageView alloc] init];
        _headerImgView.image = [UIImage imageNamed:@"juran"];
    }
    return _headerImgView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor stec_whiteTextColor];
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.textAlignment = NSTextAlignmentCenter;
        _subLabel.font = [UIFont stec_packageTitleBigFount];
//        _subLabel.text = @"18939724377";//@"登录";
        
        _subLabel.text = [self resetAccountNumber:nil];

    }
    return _subLabel;
}
@end
