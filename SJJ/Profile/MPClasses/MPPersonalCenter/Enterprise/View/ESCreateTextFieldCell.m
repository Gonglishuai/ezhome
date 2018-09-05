
#import "ESCreateTextFieldCell.h"

@interface ESCreateTextFieldCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomline;

@end

@implementation ESCreateTextFieldCell
{
    NSIndexPath *_indexPath;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getTextFieldCellDisplayInformationWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getTextFieldCellDisplayInformationWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            NSString *placeholder = dict[@"placeholder"];
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:placeholder];
            [attStr setAttributes:@{NSForegroundColorAttributeName : [UIColor stec_contentTextColor]}
                            range:NSMakeRange(0, placeholder.length)];
            self.messageTextField.attributedPlaceholder = attStr;
            self.messageTextField.text = dict[@"message"];
            self.titleLabel.text = dict[@"title"];
            self.unitLabel.text = dict[@"unit"];
            
            [self updateTextFieldKeyBoardType:dict[@"kbType"]];
        }
    }
}

- (void)updateTextFieldKeyBoardType:(NSString *)type
{
    if (!type
        || ![type isKindOfClass:[NSString class]])
    {
        return;
    }
    
    UIKeyboardType keyBoardType = UIKeyboardTypeDefault;
    if ([type isEqualToString:@"number"])
    {
        keyBoardType = UIKeyboardTypeDecimalPad;
    }
    else if ([type isEqualToString:@"phone"])
    {
        keyBoardType = UIKeyboardTypeNumberPad;
    }
    else if ([type isEqualToString:@"english"])
    {
        keyBoardType = UIKeyboardTypeASCIICapable;
    }
    else
    {
        keyBoardType = UIKeyboardTypeDefault;
        self.messageTextField.returnKeyType = UIReturnKeyDone;
    }
    
    self.messageTextField.keyboardType = keyBoardType;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldShouldBeginEditing:indexPath:)])
    {
        return [(id)self.cellDelegate textFieldShouldBeginEditing:textField
                                                        indexPath:_indexPath];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldDidBeginEditing:indexPath:)])
    {
        [(id)self.cellDelegate textFieldDidBeginEditing:textField
                                              indexPath:_indexPath];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldShouldEndEditing:indexPath:)])
    {
        return [(id)self.cellDelegate textFieldShouldEndEditing:textField
                                                      indexPath:_indexPath];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldDidEndEditing:indexPath:)])
    {
        [(id)self.cellDelegate textFieldDidEndEditing:textField
                                            indexPath:_indexPath];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
                        reason:(UITextFieldDidEndEditingReason)reason
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldDidEndEditing:reason:indexPath:)])
    {
        [(id)self.cellDelegate textFieldDidEndEditing:textField
                                               reason:reason
                                            indexPath:_indexPath];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:indexPath:)])
    {
        return [(id)self.cellDelegate textField:textField
                  shouldChangeCharactersInRange:range
                              replacementString:string
                                      indexPath:_indexPath];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldShouldClear:indexPath:)])
    {
        return [(id)self.cellDelegate textFieldShouldClear:textField
                                                 indexPath:_indexPath];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textFieldShouldReturn:indexPath:)])
    {
        return [(id)self.cellDelegate textFieldShouldReturn:textField
                                                  indexPath:_indexPath];
    }
    
    return YES;
}

@end
