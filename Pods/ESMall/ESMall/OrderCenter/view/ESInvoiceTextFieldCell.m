//
//  ESInvoiceTextFieldCell.m
//  Consumer
//
//  Created by jiang on 2017/7/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESInvoiceTextFieldCell.h"
#import "CoStringManager.h"

@interface ESInvoiceTextFieldCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) void(^myblock)(NSString*);
@property (strong, nonatomic) void(^mydropListblock)(void);
@end

@implementation ESInvoiceTextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    _inputTextField.textColor = [UIColor stec_titleTextColor];
    _inputTextField.font = [UIFont stec_subTitleFount];
    _inputTextField.backgroundColor = [UIColor stec_viewBackgroundColor];
    _inputTextField.delegate = self;
    [_inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 40)];
    view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _inputTextField.leftView = view;
    _inputTextField.leftViewMode = UITextFieldViewModeAlways;
    _inputTextField.clipsToBounds = NO;
    _inputTextField.returnKeyType = UIReturnKeyDone;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder userEnabled:(BOOL)userEnabled block:(void(^)(NSString*))block dropListblock:(void(^)(void))dropListblock{
    _myblock = block;
    _mydropListblock = dropListblock;
    _titleLabel.text = title;
    _inputTextField.placeholder = placeholder;
    _inputTextField.text = subTitle;
    _inputTextField.userInteractionEnabled = userEnabled;
    if ([title isEqualToString:@"纳税人识别号"]) {
        _inputTextField.keyboardType = UIKeyboardTypeASCIICapable;
    } else if([title isEqualToString:@"开户行账号"]) {
        _inputTextField.keyboardType = UIKeyboardTypeNumberPad;
    } else {
        _inputTextField.keyboardType = UIKeyboardTypeDefault;
    }
    
}

- (void)setFirstResponder {
    [self.inputTextField becomeFirstResponder];
    if (_mydropListblock) {
        _mydropListblock();
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 200) {
        textField.text = [textField.text substringToIndex:200];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_myblock) {
        SHLog(@"%@", [NSString stringWithFormat:@"字符串：%@", _inputTextField.text]);
        NSCharacterSet *whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *str = [[NSString alloc]initWithString:[_inputTextField.text stringByTrimmingCharactersInSet:whiteSpace]];
        _inputTextField.text = str;
        _myblock(str);
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_mydropListblock) {
        _mydropListblock();
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputTextField resignFirstResponder];
    return YES;
}

@end
