//
//  ESPasswordCell.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESPasswordCell.h"
#import "Masonry.h"


@interface ESPasswordCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UITextField *inputText;
@property (nonatomic,strong)    UIImageView *imgView;
@property (nonatomic,strong)    UIView *lineView;
@property (nonatomic,strong)    UIButton *eyeBtn;
@end
@implementation ESPasswordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(0);
            make.right.mas_offset(0);
            make.height.mas_offset(0.5);
            make.top.equalTo(self.mas_bottom).mas_offset(-0.5);
        }];
        
    }
    return self;
}

- (void)setIsCreateEyeBtn:(BOOL)isCreateEyeBtn {
    _isCreateEyeBtn = isCreateEyeBtn;
    if (isCreateEyeBtn) {
        [self createEyeBtn];
        
    }else {
        [self addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(0);
            make.right.mas_offset(0);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_offset(30);
        }];
    }
}

#pragma mark --- private method
- (void)createEyeBtn {
    UIImage *image = [UIImage imageNamed:@"eye_normal"];
    CGFloat h = image.size.height;
    CGFloat w = image.size.width;
    [self addSubview:self.eyeBtn];
    [self.eyeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.mas_offset(0);
        make.height.mas_offset(30);
        make.width.mas_offset(30 * w / h);
    }];
    
    [self addSubview:self.inputText];
    [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(0);
        make.right.equalTo(self.eyeBtn.mas_left);
        make.centerY.equalTo(self.mas_centerY);
        make.height.mas_offset(30);
    }];
}

- (void)passwordChaged:(UITextField *)textField {
    if (textField.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(esPasswordCell:textShouldChange:)]) {
            [self.delegate esPasswordCell:self textShouldChange:YES];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(esPasswordCell:textShouldChange:)]) {
            [self.delegate esPasswordCell:self textShouldChange:NO];
        }
    }
}
- (void)showPassword {
    self.inputText.secureTextEntry = !self.inputText.secureTextEntry;
    if (self.inputText.secureTextEntry) {
        [self.eyeBtn setImage:[UIImage imageNamed:@"eye_active"] forState:UIControlStateNormal];
    }else {
        [self.eyeBtn setImage:[UIImage imageNamed:@"eye_normal"] forState:UIControlStateNormal];
    }
}


#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"password_active"];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"password"];
    if ([self.delegate respondsToSelector:@selector(esPasswordCell:textDidEndEditing:)]) {
        [self.delegate esPasswordCell:self textDidEndEditing:textField.text];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputText resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.inputText.text = nil;
    return YES;
}

#pragma mark --- 懒加载
- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.placeholder = @"密码";
        _inputText.delegate = self;
        _inputText.secureTextEntry = YES;
        _inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputText.returnKeyType = UIReturnKeyDone;
        _inputText.leftView = [self leftView];
        _inputText.leftViewMode = UITextFieldViewModeAlways;
        
        [_inputText addTarget:self action:@selector(passwordChaged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputText;
}
- (UIView *)leftView {
    UIView *view = [[UIView alloc] init];
    UIImage *image = [UIImage imageNamed:@"password"];
    view.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height);
    [view addSubview:self.imgView];
    return view;
}
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"password"];
        _imgView.image = image;
        _imgView.frame  = CGRectMake(0, 0,image.size.width, image.size.height);
    }
    return _imgView;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor stec_grayBackgroundTextColor];
    }
    return _lineView;
}
- (UIButton *)eyeBtn {
    if (!_eyeBtn) {
        _eyeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"eye_normal"];
        [_eyeBtn setImage:image forState:UIControlStateNormal];
        [_eyeBtn addTarget:self action:@selector(showPassword) forControlEvents:UIControlEventTouchUpInside];
        _eyeBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    return _eyeBtn;
}
@end
