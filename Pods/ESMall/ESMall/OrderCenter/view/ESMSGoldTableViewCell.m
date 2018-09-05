//
//  ESMSGoldTableViewCell.m
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMSGoldTableViewCell.h"
#import "CoStringManager.h"

#define kAlphaNum @"0123456789"

@interface ESMSGoldTableViewCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (assign, nonatomic) NSInteger goldNum;
@property (assign, nonatomic) CGFloat canGoldNum;
@property (copy, nonatomic) NSString *textFieldOldText;

@property (strong, nonatomic) void(^myblock)(NSString *goldNum,void(^)(BOOL resetStatus));
@property (strong, nonatomic) void(^keyBoardBlock)(CGRect);
@end


@implementation ESMSGoldTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
    
    _inputTextField.textColor = [UIColor stec_titleTextColor];
    _inputTextField.font = [UIFont stec_subTitleFount];
    _inputTextField.layer.borderWidth = 0.5;
    _inputTextField.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    _inputTextField.delegate = self;
    [_inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _inputTextField.returnKeyType = UIReturnKeyDone;
    _inputTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _countLabel.textColor = [UIColor stec_subTitleTextColor];
    _countLabel.font = [UIFont stec_subTitleFount];
    
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder textFieldText:(NSString *)textFieldText block:(void(^)(NSString*,void(^)(BOOL resetStatus)))block {
    _myblock = block;
    _titleLabel.text = title;
    if (subTitle.length>0) {
        _goldNum = [subTitle integerValue];
    }
    
//    if (textFieldText.length>0) {
//        _canGoldNum = [textFieldText integerValue];
//    }
    
    _subTitleLabel.text = subTitle;
    _inputTextField.placeholder = placeholder;
    _inputTextField.text = textFieldText;
    _textFieldOldText = textFieldText;
}

- (NSString *)returnCanpointAmount:(NSMutableDictionary *)datasSource {
    NSString *pointAmount = [CoStringManager displayCheckPrice:[NSString stringWithFormat:@"%@", [datasSource objectForKey:@"userPointAmount"]]];
    if ([pointAmount isKindOfClass:[NSNull class]]) {
        pointAmount = @"0";
    }
    NSString *canpointAmount = [NSString stringWithFormat:@"%@元可用", pointAmount];
    
    return canpointAmount;
}

- (void)setCanUseGold:(NSString *)goldNum {
    _canGoldNum = [goldNum doubleValue];
}

- (void)setKeyboardBlock:(void(^)(CGRect inSuperViewFrame))block {
    _keyBoardBlock = block;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _textFieldOldText = textField.text;
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
        if (_inputTextField.text.length>0) {
            
            NSInteger num = [_inputTextField.text integerValue];
            CGFloat payGoldsNum = _canGoldNum;
            if (num > payGoldsNum
                && floor(_canGoldNum) < _canGoldNum
                && floor(_canGoldNum) + 1 <= _goldNum)
            {
                num = floor(_canGoldNum) + 1;
            }
            else if (num > MIN(_goldNum, floor(_canGoldNum)))
            {
                num = MIN(_goldNum, floor(_canGoldNum));
            }
            
            _inputTextField.text = [@(num) stringValue];
            
            __weak UITextField *weakTextFirld = _inputTextField;
            void (^_resetCallback)(BOOL) =  ^(BOOL resetStatus){
                if (resetStatus)
                {
                    weakTextFirld.text = _textFieldOldText;
                }
            };
            
            _myblock([@(num) stringValue], _resetCallback);

        } else {
            _inputTextField.text = @"0";
            _myblock(@"0", nil);
        }
        
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    CGRect rect1 = [textField convertRect:textField.frame fromView:self.contentView];//获取button在contentView的位置
    
    CGRect rect2 = [textField convertRect:rect1 toView:window];
    if (_keyBoardBlock) {
        _keyBoardBlock(rect2);
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    BOOL canChange = [string isEqualToString:filtered];
    
    return canChange;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.inputTextField resignFirstResponder];
    return YES;
}


@end
