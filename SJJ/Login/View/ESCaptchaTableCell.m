//
//  ESCaptchaTableCell.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCaptchaTableCell.h"
#import "Masonry.h"


#import "ESDeviceUtil.h"
#import "UIButton+WebCache.h"

@interface ESCaptchaTableCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UITextField *inputText;
@property (nonatomic,strong)    UIImageView *imgView;
@property (nonatomic,strong)    UIView *lineView;
@property (nonatomic,strong)    UIButton *reloadBtn;
@property (nonatomic,copy)    NSString *imageRandomCodeKey;
@property (nonatomic,strong)    UIActivityIndicatorView *indicatorView;//等待指示器
@end

@implementation ESCaptchaTableCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        

        [self addSubview:self.reloadBtn];
        [self.reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(50);
            make.right.mas_offset(0);
            make.width.mas_offset(100);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(0);
            make.right.equalTo(self.reloadBtn.mas_left).mas_offset(-5);
            make.height.mas_offset(30);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inputText.mas_left);
            make.right.mas_offset(0);
            make.height.mas_offset(0.5);
            make.top.equalTo(self.mas_bottom).offset(-0.5);
        }];
        
        [self.reloadBtn addSubview:self.indicatorView];
        self.indicatorView.center = self.reloadBtn.center;
        
        [self reloadCapatcha];
    }
    return self;
}

- (void)setIsShowIndicatorView:(BOOL)isShowIndicatorView {
    _isShowIndicatorView = isShowIndicatorView;
    if (isShowIndicatorView) {
        
        
    }
}

#pragma mark --- private method
//刷新图片验证码
- (void)reloadCapatcha {
    
    [self.indicatorView startAnimating];
    
    if (self.pageType == ESRegisterPageTypeLogin) {
        [ESLoginAPI getIdentifyingImageUrlForLiginWithType:self.pageType success:^(NSDictionary *dict) {
            SHLog(@"刷新验证码 %@",dict);
            NSString *str = dict[@"imageRandomCodeValueStream"];
            self.imageRandomCodeKey = dict[@"imageRandomCodeKey"];
            NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *image = [UIImage imageWithData:data];
            [self.reloadBtn setBackgroundImage:image forState:UIControlStateNormal];
            
            [self.indicatorView stopAnimating];
            
        } failure:^(NSError *error) {

            NSString *text = [ESLoginAPI errMessge:error];
            SHLog(@"刷新验证码失败 %@",text);
            
            [self.indicatorView stopAnimating];
        }];
    }else {
        NSString *codeUrl = [ESLoginAPI getIdentifyingImageUrlWithType:ESRegisterPageTypeCreate UUID:[ESDeviceUtil getUUID]];
        [self.reloadBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:codeUrl] forState:UIControlStateNormal completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.indicatorView stopAnimating];
            
        }];
    }
    

}
- (void)textDidChanged:(UITextField *)textField {
    if (textField.text.length >= 4) {
        if ([self.delegate respondsToSelector:@selector(esCaptchaTableCell:textShouldChange:)]) {
            [self.delegate esCaptchaTableCell:self textShouldChange:YES];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(esCaptchaTableCell:textShouldChange:)]) {
            [self.delegate esCaptchaTableCell:self textShouldChange:NO];
        }
    }
    
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"sms_active"];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"sms"];
    if ([self.delegate respondsToSelector:@selector(esCaptchaTableCell:textDidEndEditing:imageRandomCodeKey:)]) {
        [self.delegate esCaptchaTableCell:self textDidEndEditing:textField.text imageRandomCodeKey:self.imageRandomCodeKey];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputText resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger strLength = textField.text.length - range.length + string.length;
    return (strLength <= 4);
}
#pragma mark -- 懒加载
- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.placeholder = @"输入验证码";
        _inputText.delegate = self;
        _inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputText.returnKeyType = UIReturnKeyDone;
        _inputText.secureTextEntry = YES;
        _inputText.leftView = [self leftView];
        _inputText.leftViewMode = UITextFieldViewModeAlways;
        [_inputText addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputText;
}
- (UIView *)leftView {
    UIView *view = [[UIView alloc] init];
    UIImage *image = [UIImage imageNamed:@"sms"];
    view.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height);
    [view addSubview:self.imgView];
    return view;
}
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"sms"];
        _imgView.image = image;
        _imgView.frame  = CGRectMake(0, 0,image.size.width, image.size.height);
    }
    return _imgView;
}

- (UIButton *)reloadBtn {
    if (!_reloadBtn) {
        _reloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadBtn addTarget:self action:@selector(reloadCapatcha) forControlEvents:UIControlEventTouchUpInside];
        _reloadBtn.highlighted = NO;
    }
    return _reloadBtn;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor stec_grayBackgroundTextColor];
    }
    return _lineView;
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

@end
