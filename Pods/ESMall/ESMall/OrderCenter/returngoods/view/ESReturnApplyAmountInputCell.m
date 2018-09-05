
#import "ESReturnApplyAmountInputCell.h"

@interface ESReturnApplyAmountInputCell ()<UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textInput;

@end

@implementation ESReturnApplyAmountInputCell
{
    BOOL _hasDian;
    
    CGFloat _returnAmount;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getReturnAmountWithIndexPath:)])
    {
        NSString *amount = [self.cellDelegate getReturnAmountWithIndexPath:indexPath];
        if (amount
            && [amount isKindOfClass:[NSString class]]
            && [amount rangeOfString:@"¥"].length > 0)
        {
            _returnAmount = [[amount substringFromIndex:1] doubleValue];
        }
            
        self.textInput.text = @"";
    }
    
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(returnAmountDidEndEditing:)])
    {
        if ([textField.text doubleValue] > _returnAmount)
        {
            textField.text = [@(_returnAmount) stringValue];
        }
        
        if ([textField.text doubleValue] <= 0)
        {
            textField.text = @"0";
        }
        
        [self.cellDelegate returnAmountDidEndEditing:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 删除键
    if ([string isEqualToString:@""]
        && [string integerValue] == 0)
    {
        return YES;
    }
    
    // 判断是否有小数点
    if ([textField.text rangeOfString:@"."].length > 0)
    {
        _hasDian = YES;
    }
    else
    {
        _hasDian = NO;
    }
    
    if (string.length > 0)
    {
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.'))
        {
            return NO;
        }
        
        // 只能有一个小数点
        if (_hasDian && single == '.')
        {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.'))
        {
            textField.text = @"0";
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"])
        {
            if (textField.text.length > 1)
            {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."])
                {
                    return NO;
                }
            }
            else
            {
                if (![string isEqualToString:@"."])
                {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (_hasDian)
        {
            NSRange ran = [textField.text rangeOfString:@"."];
            if (range.location > ran.location)
            {
                if ([textField.text pathExtension].length > 1)
                {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)textFieldDidChanged:(UITextField *)textField
{
    
}

@end
