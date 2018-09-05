//
//  ESModifyPasswordTableCell.m
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESModifyPasswordTableCell.h"
#import "Masonry.h"

@interface ESModifyPasswordTableCell ()<UITextFieldDelegate>
@property (nonatomic,strong)    UITextField *inputText;

@end

@implementation ESModifyPasswordTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.inputText];
        [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(0);
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
            make.bottom.mas_offset(-1);
        }];
        
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inputText.mas_left);
            make.right.equalTo(self.inputText.mas_right);
            make.height.mas_offset(0.5);
            make.top.equalTo(self.inputText.mas_bottom).offset(1);
        }];
    }
    return self;
}


- (void)setPlacehorder:(NSString *)placehorder {
    _placehorder = placehorder;
    self.inputText.placeholder = placehorder;
}

#pragma mark --- UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(esModifyPasswordTableCell:textDidEndEditing:)]) {
        [self.delegate esModifyPasswordTableCell:self textDidEndEditing:textField.text];
    }
}

- (UITextField *)inputText {
    if (!_inputText) {
        _inputText = [[UITextField alloc] init];
        _inputText.secureTextEntry = YES;
        _inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        
    }
    return _inputText;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor stec_grayBackgroundTextColor];
    }
    return _lineView;
}
@end
