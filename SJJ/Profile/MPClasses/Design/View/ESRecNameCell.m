//
//  ESReNameCell.m
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecNameCell.h"
#import <Masonry.h>
#import "MTPFormCheck.h"

@interface ESRecNameCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UITextField *textInput;

@end

@implementation ESRecNameCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.textInput];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(15);
            make.left.equalTo(self.mas_left).offset(17);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(20);
        }];
        [self.textInput mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right).offset(36);
            make.top.equalTo(self.titleLabel.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(self.titleLabel);
        }];
        
    }
    return self;
}


- (void)setCellType:(ESRecNameCellType)cellType {
    _cellType = cellType;
    switch (cellType) {
        case ESRecNameCellTypeName:
            self.titleLabel.text = @"业主姓名";
            self.textInput.placeholder = @"请输入客户姓名";
            self.textInput.keyboardType = UIKeyboardTypeDefault;
            break;
        case ESRecNameCellTypePhoneNumber:
            self.titleLabel.text = @"手机号码";
            self.textInput.placeholder = @"请输入客户手机号码";
            self.textInput.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            break;
    }
}

#pragma mark 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor blackColor];//#000000 100%

    }
    return _titleLabel;
}

- (UITextField *)textInput {
    if (!_textInput) {
        _textInput = [[UITextField alloc] init];
        _textInput.returnKeyType = UIReturnKeyDone;
        _textInput.font = [UIFont systemFontOfSize:14];
        _textInput.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textInput.delegate = self;
    }
    return _textInput;
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.cellType == ESRecNameCellTypePhoneNumber) {//
        if (textField.text.length == 0 || textField.text == nil) {
            return;
        }
        BOOL isValidNumber = [MTPFormCheck chectMobile:textField.text];
        if (isValidNumber) {
            if ([self.delegate respondsToSelector:@selector(esRecNameCell:phoneNumber:)]) {
                [self.delegate esRecNameCell:self phoneNumber:textField.text];
            }
        }else {
            if ([self.delegate respondsToSelector:@selector(esRecNameCell:cellType:reminder:)]) {
                [self.delegate esRecNameCell:self cellType:self.cellType reminder:@"手机号码格式不正确"];
            }
        }
    }else {
        NSString *nameStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (nameStr.length == 0) {
//            if ([self.delegate respondsToSelector:@selector(esRecNameCell:cellType:reminder:)]) {
//                [self.delegate esRecNameCell:self cellType:self.cellType reminder:@"请输入业主姓名"];
//            }
        }else {
            if ([self.delegate respondsToSelector:@selector(esRecNameCell:name:)]) {
                [self.delegate esRecNameCell:self name:textField.text];
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *originText = textField.text;
    NSString *resultText = [originText stringByReplacingCharactersInRange:range withString:string];
    
    if (self.cellType == ESRecNameCellTypePhoneNumber) {
        if (resultText.length > 11 && resultText.length > originText.length) {
            return NO;
        }
    }else {
        if (resultText.length > 16 && resultText.length > originText.length) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
@end
