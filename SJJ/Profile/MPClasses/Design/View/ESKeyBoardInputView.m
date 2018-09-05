//
//  ESKeyBoardInputView.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESKeyBoardInputView.h"
#import "MBProgressHUD+NJ.h"
#import "CoStringManager.h"

@interface ESKeyBoardInputView()<UITextFieldDelegate>

@property (strong, nonatomic) void(^myblock)(NSString*);
@end

@implementation ESKeyBoardInputView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _textField.textColor = [UIColor stec_titleTextColor];
    _textField.textColor = [UIColor stec_titleTextColor];
    _textField.font = [UIFont stec_titleFount];
    _textField.delegate = self;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

+ (instancetype)creatWithPlacetitle:(NSString *)placeTitle title:(NSString *)title Block:(void(^)(NSString*))block {
    ESKeyBoardInputView *inputView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    inputView.myblock = block;
    if (placeTitle) {
        inputView.textField.placeholder = placeTitle;
    }
    if (title) {
        inputView.textField.text = title;
    }
    return inputView;
}

- (void)setWithPlacetitle:(NSString *)placeTitle title:(NSString *)title {
    if (placeTitle) {
        self.textField.placeholder = placeTitle;
    }
    if (title) {
        self.textField.text = title;
    }
    
}

#pragma mark textFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 50) {
        textField.text = [textField.text substringToIndex:50];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
     textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UIWindow *win=[[UIApplication sharedApplication].windows objectAtIndex:1];
    if (textField.text.length < 5) {
        [MBProgressHUD showError:@"评论内容不足5个字符" toView:win];
        return NO;
    } else if([CoStringManager stringContainsEmoji:textField.text]) {
        [MBProgressHUD showError:@"评论含有特殊字符" toView:win];
        return NO;
    } else {
        //取消第一响应项
        
        [textField resignFirstResponder];
        if (_myblock) {
            SHLog(@"%@", [NSString stringWithFormat:@"字符串：%@", textField.text]);
            _myblock(textField.text);
        }
        textField.text = @"";
        return YES;
    }
}

- (void)dealloc {
    SHLog(@"ESKeyBoardInputView页面释放");
}

@end
