//
//  ESBottomTableCell.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESBottomTableCell.h"
#import "ESRegisterProtocolController.h"

#import "Masonry.h"

#import "ESPublicMethods.h"

@interface ESBottomTableCell ()
@property (nonatomic,strong)    UIButton *sendBtn;
@property (nonatomic,strong)    UIButton *bottomLeftBtn;
@property (nonatomic,strong)    UIButton *bottomRightBtn;
@property (nonatomic,strong)    UIButton *bottomCenterBtn;
@property (nonatomic,strong)    UILabel *bottomlabel;
@end

@implementation ESBottomTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.sendBtn];
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.left.mas_offset(0);
            make.right.mas_offset(0);
            make.height.mas_offset(50);
        }];
        
    }
    return self;
}

- (void)setBottomBtnStyle:(ESBottomBtnStyle)bottomBtnStyle {
    _bottomBtnStyle = bottomBtnStyle;
    switch (bottomBtnStyle) {
        case ESBottomBtnStyleDefault:
            [self.sendBtn setTitle:@"完成" forState:UIControlStateNormal];
            break;
        case ESBottomBtnStyleRegisterAndGetBackPassword:
            [self createBottomWithRegisterBtn];
            [self createBottomWithGetBackPasswordBtn];
            [self.sendBtn setTitle:@"登录" forState:UIControlStateNormal];
            break;
        case ESBottomBtnStyleProtocol:
            [self createBottomWithRegisterProtocol];
            [self.sendBtn setTitle:@"获取短信验证码" forState:UIControlStateNormal];
            break;
        case ESBottomBtnStyleGetBackPassword:
            [self createBottomWithGetBackPasswordBtn];
            [self.sendBtn setTitle:@"登录" forState:UIControlStateNormal];
            break;
        case ESBottomBtnStyleOtherAccountAndGetBackPassword:
            [self createBottomWithOtherAccountBtn];
            [self createBottomWithGetBackPasswordBtn];
            [self.sendBtn setTitle:@"登录" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
- (void)setBottomBtnTitle:(NSString *)bottomBtnTitle {
    _bottomBtnTitle = bottomBtnTitle;
    [self.sendBtn setTitle:bottomBtnTitle forState:UIControlStateNormal];
}

#pragma mark --- private method
- (void)sendAction {
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(registerBtnAction)]) {
        [self.delegate registerBtnAction];
    }
}
- (void)forgetPassword {
    if ([self.delegate respondsToSelector:@selector(getBackPasswordAction)]) {
        [self.delegate getBackPasswordAction];
    }
}
- (void)registerAction {
    if ([self.delegate respondsToSelector:@selector(esBottomTableCellBottomLeftBtnAction)]) {
        [self.delegate esBottomTableCellBottomLeftBtnAction];
    }
}
//设计家注册协议
- (void)showProtocolMsg {
    ESRegisterProtocolController *protocolVC = [[ESRegisterProtocolController alloc] init];
    UIViewController *vc = [ESPublicMethods currentViewController];
    [vc.navigationController presentViewController:protocolVC animated:YES completion:nil];
}
///创建找回密码按钮
- (void)createBottomWithGetBackPasswordBtn {
    [self addSubview:self.bottomRightBtn];
    [self.bottomRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendBtn.mas_bottom).offset(15);
        make.right.equalTo(self.sendBtn.mas_right);
        make.height.mas_offset(30);
        make.width.mas_offset(80);
    }];
}
///创建注册按钮
- (void)createBottomWithRegisterBtn {
    [self addSubview:self.bottomLeftBtn];
    [self.bottomLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sendBtn);
        make.top.equalTo(self.sendBtn.mas_bottom).offset(15);
        make.height.mas_offset(30);
        make.width.mas_offset(100);
    }];
}
///创建协议按钮
- (void)createBottomWithRegisterProtocol {
    [self addSubview:self.bottomlabel];
    [self.bottomlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sendBtn.mas_bottom).offset(15);
//        make.left.equalTo(self.sendBtn.mas_left).offset(10);
        make.right.equalTo(self.sendBtn.mas_centerX).offset(-20);
        make.height.mas_offset(30);
    }];
    [self addSubview:self.bottomCenterBtn];
    [self.bottomCenterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomlabel.mas_top).offset(0);
        make.bottom.equalTo(self.bottomlabel.mas_bottom).offset(0);
        make.left.equalTo(self.bottomlabel.mas_right);
    }];
    
}
//创建“其他账号登录”按钮
- (void)createBottomWithOtherAccountBtn {
    [self addSubview:self.bottomLeftBtn];
    [self.bottomLeftBtn setTitle:@"其他账号登录" forState:UIControlStateNormal];
    [self.bottomLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sendBtn);
        make.top.equalTo(self.sendBtn.mas_bottom).offset(15);
        make.height.mas_offset(30);
        make.width.mas_offset(100);
    }];
}

#pragma mark --- public method
- (void)resetBottomStyle:(BOOL)userInteractionEnabled {
    self.sendBtn.userInteractionEnabled = userInteractionEnabled;
    if (userInteractionEnabled) {
        self.sendBtn.backgroundColor = [UIColor stec_blueTextColor];
        [self.sendBtn setTitleColor:[UIColor stec_whiteTextColor] forState:UIControlStateNormal];
    }else {
        self.sendBtn.backgroundColor = [UIColor stec_unabelButtonBackColor];
        [self.sendBtn setTitleColor:[UIColor stec_grayTextColor] forState:UIControlStateNormal];
    }
}

#pragma mark --- 懒加载
- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [_sendBtn setTitle:@"提交" forState:UIControlStateNormal];
        _sendBtn.backgroundColor = [UIColor stec_unabelButtonBackColor];
        [_sendBtn setTitleColor:[UIColor stec_grayTextColor] forState:UIControlStateNormal];
        _sendBtn.userInteractionEnabled = NO;
        _sendBtn.layer.cornerRadius = 5;
        _sendBtn.layer.masksToBounds = YES;
    }
    return _sendBtn;
}
- (UIButton *)bottomLeftBtn {
    if (!_bottomLeftBtn) {
        _bottomLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomLeftBtn addTarget:self action:@selector(registerAction) forControlEvents:UIControlEventTouchUpInside];
        [_bottomLeftBtn setTitle:@"注册" forState:UIControlStateNormal];
        _bottomLeftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _bottomLeftBtn.titleLabel.font = [UIFont stec_priceFount];
        [_bottomLeftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _bottomLeftBtn;
}
- (UIButton *)bottomRightBtn {
    if (!_bottomRightBtn) {
        _bottomRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomRightBtn addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
        [_bottomRightBtn setTitle:@"找回密码" forState:UIControlStateNormal];
        _bottomRightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _bottomRightBtn.titleLabel.font = [UIFont stec_priceFount];
        [_bottomRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _bottomRightBtn;
}
- (UILabel *)bottomlabel {
    if (!_bottomlabel) {
        _bottomlabel = [[UILabel alloc] init];
        _bottomlabel.text = @"注册代表你同意";
        _bottomlabel.textColor = [UIColor stec_grayTextColor];
        _bottomlabel.textAlignment = NSTextAlignmentLeft;
        _bottomlabel.font = [UIFont stec_paramsFount];
    }
    return _bottomlabel;
}
- (UIButton *)bottomCenterBtn {
    if (!_bottomCenterBtn) {
        _bottomCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomCenterBtn addTarget:self action:@selector(showProtocolMsg) forControlEvents:UIControlEventTouchUpInside];
        [_bottomCenterBtn setTitle:@"《居然设计家网站注册协议》" forState:UIControlStateNormal];
        _bottomCenterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _bottomCenterBtn.titleLabel.font = [UIFont stec_priceFount];
        [_bottomCenterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _bottomCenterBtn;
}
@end
