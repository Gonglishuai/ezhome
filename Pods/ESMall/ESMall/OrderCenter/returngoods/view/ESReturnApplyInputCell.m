//
//  ESReturnApplyInputCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnApplyInputCell.h"

@implementation ESReturnApplyInputCell
{
    __weak IBOutlet UILabel *_applyInputTitleLabel;
    __weak IBOutlet UITextField *_applyInputTextField;
    NSInteger _index;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _applyInputTextField.borderStyle = UITextBorderStyleNone;
}

- (void)updateApplyInputCell:(NSInteger)index {
    _index = index;
    if ([self.delegate respondsToSelector:@selector(getInputTitle:)]) {
        _applyInputTitleLabel.text = [self.delegate getInputTitle:index];
    }
    if ([self.delegate respondsToSelector:@selector(getInputContent:)]) {
        _applyInputTextField.text = [self.delegate getInputContent:index];
    }
    if ([self.delegate respondsToSelector:@selector(getInputPlaceHolder:)]) {
        _applyInputTextField.placeholder = [self.delegate getInputPlaceHolder:index];
    }
}

- (IBAction)textFieldEndEdit:(UITextField *)sender {
    if ([self.delegate respondsToSelector:@selector(setInputContent:withIndex:)]) {
        [self.delegate setInputContent:sender.text withIndex:_index];
    }
}

- (void)focusTextField {
    [_applyInputTextField becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }

    return YES;
}
@end
