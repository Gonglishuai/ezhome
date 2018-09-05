//
//  ESNoteCodeTableCell.m
//  Homestyler
//
//  Created by shiyawei on 27/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESNoteCodeTableCell.h"

#import "Masonry.h"

@interface ESNoteCodeTableCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UITextField *inputText;
@property (nonatomic,strong)    UIButton *reloadCodeBtn;
@property (nonatomic,strong)    UIView *lineView;
@property (nonatomic,strong)    UIImageView *imgView;
@property (nonatomic,strong)    NSTimer *timer;
@property (nonatomic,assign)    NSTimeInterval timeInterval;
@end

@implementation ESNoteCodeTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.timeInterval = 60;
        
        [self addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(0);
            make.right.mas_offset(0);
            make.height.mas_offset(30);
            make.centerY.equalTo(self.mas_centerY);
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


#pragma mark --- private method
- (void)textDidChanged:(UITextField *)textField {
    if (textField.text.length >= 6) {
        if ([self.delegate respondsToSelector:@selector(esNoteCodeTableCell:textShouldChange:)]) {
            [self.delegate esNoteCodeTableCell:self textShouldChange:YES];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(esNoteCodeTableCell:textShouldChange:)]) {
            [self.delegate esNoteCodeTableCell:self textShouldChange:NO];
        }
    }
}
//重新获取短信验证码
- (void)reloadNoteCodeAction {
    if ([self.delegate respondsToSelector:@selector(esNoteCodeTableCellReloadNoteCode)]) {
        [self.delegate esNoteCodeTableCellReloadNoteCode];
    }
}

#pragma mark --- publick method
- (void)invalidateTimer {
    [self.reloadCodeBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
    self.reloadCodeBtn.userInteractionEnabled = YES;
    [self.timer invalidate];
    self.timer = nil;
}
//开启定时器
- (void)fireTimer {
    if (self.timer != nil) {
        return;
    }
    self.timeInterval = 60;
    self.reloadCodeBtn.userInteractionEnabled = NO;
    [self.timer fire];
}
//时间自减
- (void)timerSubtract {
    self.reloadCodeBtn.userInteractionEnabled = NO;
    self.timeInterval--;
    if (self.timeInterval == 0) {
        self.timeInterval = 60;
        [self invalidateTimer];
        
        if (self.cellBlock) {
            self.cellBlock();
        }
        
        return;
    }else {
        [self.reloadCodeBtn setTitle:[NSString stringWithFormat:@"%.0fs",self.timeInterval] forState:UIControlStateNormal];
    }
}
#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"sms_active"];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.imgView.image = [UIImage imageNamed:@"sms"];
    if ([self.delegate respondsToSelector:@selector(esNoteCodeTableCell:textDidEndEditing:)]) {
        [self.delegate esNoteCodeTableCell:self textDidEndEditing:textField.text];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputText resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger strLength = textField.text.length - range.length + string.length;
    return (strLength <= 6);
}
#pragma mark --- 懒加载
- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.placeholder = @"短信验证码";
        _inputText.delegate = self;
        _inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputText.returnKeyType = UIReturnKeyDone;
        _inputText.leftView = [self leftView];
        _inputText.leftViewMode = UITextFieldViewModeAlways;
        _inputText.keyboardType = UIKeyboardTypeNumberPad;
        [_inputText addTarget:self action:@selector(textDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _inputText.rightView = self.reloadCodeBtn;
        _inputText.rightViewMode = UITextFieldViewModeAlways;
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
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor stec_grayBackgroundTextColor];
    }
    return _lineView;
}
-(UIButton *)reloadCodeBtn {
    if (!_reloadCodeBtn) {
        _reloadCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloadCodeBtn addTarget:self action:@selector(reloadNoteCodeAction) forControlEvents:UIControlEventTouchUpInside];
        _reloadCodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_reloadCodeBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        [_reloadCodeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _reloadCodeBtn.frame = CGRectMake(0, 0, 100, 45);
        _reloadCodeBtn.titleLabel.font = [UIFont stec_phoneNumberFount];
    }
    return _reloadCodeBtn;
}
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerSubtract) userInfo:nil repeats:YES];
         [[NSRunLoop currentRunLoop] addTimer:_timer forMode:UITrackingRunLoopMode];
        
    }
    return _timer;
}
@end
