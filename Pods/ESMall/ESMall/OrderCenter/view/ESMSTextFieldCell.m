//
//  ESMSTextFieldCell.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSTextFieldCell.h"
#import "CoStringManager.h"

@interface ESMSTextFieldCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *subTextField;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (strong, nonatomic) void(^myblock)(NSString*);
@property (strong, nonatomic) void(^keyBoardBlock)(CGRect);
@end

@implementation ESMSTextFieldCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_subTitleFount];
    _subTextField.textColor = [UIColor stec_titleTextColor];
    _subTextField.font = [UIFont stec_subTitleFount];
    _subTextField.delegate = self;
    [_subTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _subTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _subTextField.returnKeyType = UIReturnKeyDone;
    
}
- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle placeholder:(NSString *)placeholder arrowHidden:(BOOL)arrowHidden block:(void(^)(NSString*))block {
    _myblock = block;
    _titleLabel.text = title;
    _subTextField.placeholder = placeholder;
    _subTextField.text = subTitle;
    _arrowImageView.hidden = arrowHidden;
    _subTextField.userInteractionEnabled = arrowHidden;
    
}

- (void)setDeliveryTime:(NSMutableDictionary *)updateDic indexPath:(NSIndexPath *)indexPath {
    NSArray *pendingOrders = [updateDic objectForKey:@"pendingOrders"] ? [updateDic objectForKey:@"pendingOrders"] : [NSArray array];
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (pendingOrders.count > indexPath.section-1) {
        pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
    }
    NSString *time = pendDic[@"dispatchTime"] ? pendDic[@"dispatchTime"] : @"";
    [self setTitle:@"配送时间:" subTitle:time placeholder:@"请选择配送时间（必填）" arrowHidden:NO block:nil];

}

- (NSString *)returnBuyerMessage:(NSIndexPath *)indexPath updateDic:(NSMutableDictionary *)updateDic {
    NSArray *pendingOrders = [updateDic objectForKey:@"pendingOrders"] ? [updateDic objectForKey:@"pendingOrders"] : [NSArray array];
    NSDictionary *pendDic = [NSDictionary dictionary];
    if (pendingOrders.count>indexPath.section-1) {
        pendDic = [pendingOrders objectAtIndex: indexPath.section-1];
    }
    NSString *remark = pendDic[@"remark"] ? pendDic[@"remark"] : @"";
    return remark;
}

- (void)setKeyboardBlock:(void(^)(CGRect inSuperViewFrame))block {
    _keyBoardBlock = block;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 200) {
        textField.text = [textField.text substringToIndex:200];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_myblock) {
        SHLog(@"%@", [NSString stringWithFormat:@"字符串：%@", _subTextField.text]);
        _myblock(_subTextField.text);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.subTextField resignFirstResponder];
    return YES;
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


//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([CoStringManager stringContainsEmoji:string]) {
//        return NO;
//    }
//    return YES;
//}

@end
