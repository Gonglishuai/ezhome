//
//  ESReDetailAddressCell.m
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecDetailAddressCell.h"

@interface ESRecDetailAddressCell ()<UITextViewDelegate>
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *placeholderLabel;
@property (nonatomic,strong)    UITextView *textInput;
@end

@implementation ESRecDetailAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.textInput];
    }
    return self;
}

#pragma mark 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"详细地址";
        _titleLabel.textColor = ColorFromRGA(0x000000, 1.0);//#000000 100%
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.frame = CGRectMake(17, 13, 120, 20);
    }
    return _titleLabel;
}
- (UITextView *)textInput {
    if (!_textInput) {
        _textInput = [[UITextView alloc] init];
        _textInput.frame = CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.titleLabel.frame) + 13, SCREEN_WIDTH - 70, 70);
        _textInput.delegate = self;
        _textInput.font = [UIFont systemFontOfSize:14];
        _textInput.returnKeyType = UIReturnKeyDone;
        _textInput.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_textInput addSubview:self.placeholderLabel];
    }
    return _textInput;
}
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textColor = ColorFromRGA(0xC7D1D6, 1.0);//#C7D1D6 100%
        _placeholderLabel.text = @"请输入详细地址";
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.frame = CGRectMake(0,0,120,20);
    }
    return _placeholderLabel;
}

#pragma mark --- UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.placeholderLabel.hidden = YES;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }else {
        NSString *nameStr = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([self.delegate respondsToSelector:@selector(esRecDetailAddressCell:didEndEditing:)]) {
            [self.delegate esRecDetailAddressCell:self didEndEditing:nameStr];
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text  {
    NSString *originText = textView.text;
    NSString *resultText = [originText stringByReplacingCharactersInRange:range withString:text];
    if (resultText.length > 32 && resultText.length > originText.length) {
        return NO;
    }
    if ([text isEqual:@"\n"]) {//判断按的是不是return
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
