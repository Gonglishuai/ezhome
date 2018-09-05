//
//  ESEditAddressView.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESEditAddressView.h"
#import <Masonry.h>

@interface ESEditAddressView()<UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@end
@implementation ESEditAddressView
{
    __weak IBOutlet UITextField *_nameTextField;
    __weak IBOutlet UITextField *_phoneTextField;
    __weak IBOutlet UIView *_addrBackView;
    __weak IBOutlet UILabel *_addrLabel;
    __weak IBOutlet UIView *_addrDetailBackView;
    __weak IBOutlet UITextView *_addrDetailTextView;
    __weak IBOutlet UIButton *_saveBtn;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _nameTextField.borderStyle = UITextBorderStyleNone;
    _phoneTextField.borderStyle = UITextBorderStyleNone;
    [_saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT));
    }];
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _saveBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (IBAction)tapRootView:(UITapGestureRecognizer *)sender {
//    [self checkInput];
    [self endEditing:YES];
}

- (IBAction)saveBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(saveAddress)]) {
        [self.delegate saveAddress];
    }
}

- (IBAction)tapAddress:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(tapSelectAddress)]) {
        [self.delegate tapSelectAddress];
    }
}

- (void)updateEditView {
    if ([self.delegate respondsToSelector:@selector(getAddressName)]) {
        _nameTextField.text = [self.delegate getAddressName];
    }
    if ([self.delegate respondsToSelector:@selector(getAddressPhone)]) {
        _phoneTextField.text = [self.delegate getAddressPhone];
    }
    
    if ([self.delegate respondsToSelector:@selector(getLocation)]) {
        NSString *text = [self.delegate getLocation];
        BOOL empty = !text || [text isEqualToString:@""];
        [_addrLabel setTextColor: !empty ? [UIColor blackColor] : ColorFromRGA(0xc7c7cd, 1)];
        _addrLabel.text = !empty ? text : @"请选择";
    }
    
    if ([self.delegate respondsToSelector:@selector(getAddressDetail)]) {
        _addrDetailTextView.text = [self.delegate getAddressDetail];
        self.placeholderLabel.hidden = _addrDetailTextView.text.length > 0;
    }
    
//    [self checkInput];
}

- (void)checkInput {
    BOOL nameFlag = _nameTextField.text.length > 0;
    BOOL phoneFlag = _phoneTextField.text.length == 11;
    BOOL detailFlag = _addrDetailTextView.text.length > 0;
    
    BOOL saveBtnFlag = nameFlag && phoneFlag && detailFlag;
    [_saveBtn setBackgroundColor: saveBtnFlag ? ColorFromRGA(0x2696C4, 1) : ColorFromRGA(0xC9C9CE, 1)];
    [_saveBtn setEnabled: saveBtnFlag];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    
    if (textField == _nameTextField) {
        if (range.location >= 15) {
            return NO;
        }
    }
    
    if (textField == _phoneTextField) {
        if (range.location > 10) {
            return NO;
        }
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldBeginEditing)]) {
        [self.delegate textFieldBeginEditing];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSMutableDictionary *address = [NSMutableDictionary dictionary];
    if (textField == _nameTextField) {
        [address setObject:_nameTextField.text forKey:@"name"];
    }
    if (textField == _phoneTextField) {
        [address setObject:_phoneTextField.text forKey:@"phone"];

    }
    if ([self.delegate respondsToSelector:@selector(textFieldEndEditing:)]) {
        [self.delegate textFieldEndEditing:address];
    }
    
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSMutableDictionary *address = [NSMutableDictionary dictionary];
    if (textView == _addrDetailTextView) {
        [address setObject:_addrDetailTextView.text forKey:@"addressInfo"];
    }
    if ([self.delegate respondsToSelector:@selector(textFieldEndEditing:)]) {
        [self.delegate textFieldEndEditing:address];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location >= 60) {
        return NO;
    }
    return YES;
}

@end
