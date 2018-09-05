//
//  ESLoginChoiceView.m
//  Homestyler
//
//  Created by shiyawei on 29/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESLoginChoiceView.h"

#import "ESRegisterViewController.h"
#import "ESLoginViewController.h"

#import "Masonry.h"

@interface ESLoginChoiceView ()
@property (nonatomic,strong)    UIImageView *backgroundImgView;
@property (nonatomic,strong)    UIImageView *headerImgView;
@property (nonatomic,strong)    UILabel *welcomeLabel;
@property (nonatomic,strong)    UIButton *registBtn;
@property (nonatomic,strong)    UIButton *loginBtn;

@end

@implementation ESLoginChoiceView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self createUIView];
}

#pragma mark --- private mathod
- (void)createUIView {
    self.backgroundImgView.frame = self.frame;
    [self addSubview:self.backgroundImgView];
    
    
    
    [self addSubview:self.headerImgView];
    [self.headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(NAVBAR_HEIGHT + 100);
        make.width.mas_offset(60);
        make.height.mas_offset (60);
    }];
    
    [self addSubview:self.welcomeLabel];
    [self.welcomeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.headerImgView.mas_bottom).offset(25);
        make.height.mas_offset(25);
    }];
    
    [self addSubview:self.registBtn];
    [self.registBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.height.mas_offset(45);
        make.centerY.equalTo(self).offset(-10);
    }];
    
    [self addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.registBtn.mas_bottom).offset(20);
        make.height.mas_offset(45);
    }];
}

//点击注册/登录
- (void)registerAction:(UIButton *)btn {
    if (btn.tag == 100) {//注册
        ESRegisterViewController *registerVC = [[ESRegisterViewController alloc] init];
        registerVC.titleName = @"注册";
        UIViewController *VC = [self currentViewController];
        [VC.navigationController pushViewController:registerVC animated:YES];
    }else {//登录
        ESLoginViewController *loginVC = [[ESLoginViewController alloc] init];
        loginVC.bottomBtnStyle = ESBottomBtnStyleGetBackPassword;
        UIViewController *VC = [self currentViewController];
        [VC.navigationController pushViewController:loginVC animated:YES];
    }
    
}
- (UIViewController*)currentViewController{
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
#pragma mark --- 懒加载

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView  = [[UIImageView alloc] init];
        _backgroundImgView.image = [UIImage imageNamed:@"login_bg_iphone"];
        _backgroundImgView.userInteractionEnabled = YES;
    }
    return _backgroundImgView;
}
- (UIImageView *)headerImgView {
    if (!_headerImgView) {
        _headerImgView  = [[UIImageView alloc] init];
        _headerImgView.image = [UIImage imageNamed:@"juran"];
        _headerImgView.userInteractionEnabled = YES;
    }
    return _headerImgView;
}
- (UILabel *)welcomeLabel {
    if (!_welcomeLabel) {
        _welcomeLabel = [[UILabel alloc] init];
        _welcomeLabel.text = @"欢迎来到设计家";
        _welcomeLabel.textColor = [UIColor stec_whiteTextColor];
        _welcomeLabel.textAlignment = NSTextAlignmentCenter;
        _welcomeLabel.font = [UIFont stec_packageTitleBigFount];
    }
    return _welcomeLabel;
}
- (UIButton *)registBtn {
    if (!_registBtn) {
        _registBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registBtn setTitle:@"注册" forState:UIControlStateNormal];
        [_registBtn setTitleColor:[UIColor stec_whiteTextColor] forState:UIControlStateNormal];
        _registBtn.titleLabel.font = [UIFont stec_buttonFount];
        [_registBtn setBackgroundColor:[UIColor stec_blueTextColor]];
        _registBtn.layer.cornerRadius = 5;
        _registBtn.layer.masksToBounds = YES;
        _registBtn.tag = 100;
        [_registBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registBtn;
}
- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont stec_buttonFount];
        [_loginBtn setBackgroundColor:[UIColor whiteColor]];
        _loginBtn.layer.cornerRadius = 5;
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.tag = 101;
        [_loginBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}
@end
