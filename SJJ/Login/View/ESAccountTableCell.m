//
//  ESAccountTableCell.m
//  Homestyler
//
//  Created by shiyawei on 25/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESAccountTableCell.h"

#import "Masonry.h"
@interface ESAccountTableCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UITextField *inputText;
@property (nonatomic,strong)    UIImageView *imgView;
@property (nonatomic,strong)    UIView *lineView;
@end

@implementation ESAccountTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        [self addSubview:self.imgView];
        
        [self addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(0);
            make.right.mas_offset(0);
            make.centerY.equalTo(self.mas_centerY);
            make.height.mas_offset(30);
        }];
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inputText.mas_left);
            make.right.equalTo(self.inputText.mas_right);
            make.height.mas_offset(0.5);
            make.top.equalTo(self.mas_bottom).offset(-0.5);
        }];
    }
    return self;
}

- (void)setKeyBoardType:(KeyBoardType)keyBoardType {
    _keyBoardType = keyBoardType;
    switch (keyBoardType) {
        case KeyboardTypeNumber:
            self.inputText.keyboardType = UIKeyboardTypeNumberPad;
            self.inputText.placeholder = @"手机号";
            break;
            
        default:
            break;
    }
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"phone_active"];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"phone_normal"];
    if ([self.delegate respondsToSelector:@selector(esAccountTableCell:textDidEndEditing:)]) {
        [self.delegate esAccountTableCell:self textDidEndEditing:textField.text];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputText resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.keyBoardType == KeyboardTypeNumber) {//纯数字键盘
        NSInteger strLength = textField.text.length - range.length + string.length;
        return (strLength <= 11);
    }
    return YES;
}
#pragma mark --- 输入框字段变化
- (void)textDidChanged:(UITextField *)textField {
    if (textField.text.length > 0) {
        if ([self.delegate respondsToSelector:@selector(esAccountTableCell:textShouldChange:)]) {
            [self.delegate esAccountTableCell:self textShouldChange:YES];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(esAccountTableCell:textShouldChange:)]) {
            [self.delegate esAccountTableCell:self textShouldChange:NO];
        }
    }
}

- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.placeholder = @"手机/邮箱";
        _inputText.delegate = self;
        _inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputText.returnKeyType = UIReturnKeyDone;
        _inputText.leftView = [self leftView];
        _inputText.leftViewMode = UITextFieldViewModeAlways;
        [_inputText addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _inputText;
}
- (UIView *)leftView {
    UIView *view = [[UIView alloc] init];
    UIImage *image = [UIImage imageNamed:@"phone_normal"];
    view.frame = CGRectMake(0, 0, image.size.width + 10, image.size.height);
    [view addSubview:self.imgView];
    return view;
}
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"phone_normal"];
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
@end
