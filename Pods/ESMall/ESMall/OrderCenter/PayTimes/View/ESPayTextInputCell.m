
#import "ESPayTextInputCell.h"

@interface ESPayTextInputCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *payTextField;

@end

@implementation ESPayTextInputCell
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
        && [self.cellDelegate respondsToSelector:@selector(getPayTextInputDataWithIndexPath:)])
    {
        NSDictionary *dict = [(id)self.cellDelegate getPayTextInputDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]]
            && dict[@"payAmount"]
            && [dict[@"payAmount"] isKindOfClass:[NSString class]])
        {
            self.payTextField.text = dict[@"payAmount"];
        }
    }

}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.contentView endEditing:YES];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(payAmountTextFieldDidEndEditing:indexPath:)])
    {
        [(id)self.cellDelegate payAmountTextFieldDidEndEditing:textField.text
                                                     indexPath:_indexPath];
    }
}

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        return [(id)self.cellDelegate textField:textField
                  shouldChangeCharactersInRange:range
                              replacementString:string];
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
