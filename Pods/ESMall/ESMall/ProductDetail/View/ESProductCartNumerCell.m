
#import "ESProductCartNumerCell.h"

@interface ESProductCartNumerCell ()

@property (weak, nonatomic) IBOutlet UIButton *lessButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;

@end

@implementation ESProductCartNumerCell
{
    NSInteger _num;
    NSInteger _maxNum;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    [self createToolBarForTextField];
}

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateCartButtonStatus];
    
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(getCartNumberEnableStatus)]
        && [self.cellDelegate respondsToSelector:@selector(getCartNumber)]
        && [self.cellDelegate respondsToSelector:@selector(getMaxCartNumber)])
    {
        NSInteger number = [(id)self.cellDelegate getCartNumber];
        self.countTextField.text = [@(number) description];
        _num = number;
        _maxNum = [(id)self.cellDelegate getMaxCartNumber];
        
        BOOL enableStatus = [(id)self.cellDelegate getCartNumberEnableStatus];
        if (enableStatus)
        {
            [self updateCartButtonStatus];
        }
        else
        {
            self.lessButton.enabled = NO;
            self.moreButton.enabled = NO;
            self.countTextField.enabled = NO;
        }
    }
}

#pragma mark - Button Methods
- (IBAction)lessButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(cartNumberButtonDidTappedWithNumber:)])
    {
        [self updateCartCellWithMoreStatus:NO];
        
        [(id)self.cellDelegate cartNumberButtonDidTappedWithNumber:[self.countTextField.text integerValue]];
        
        [self updateCartButtonStatus];
    }
}

- (IBAction)moreButtonDidTapped:(id)sender
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(cartNumberButtonDidTappedWithNumber:)])
    {
        [self updateCartCellWithMoreStatus:YES];

        [(id)self.cellDelegate cartNumberButtonDidTappedWithNumber:[self.countTextField.text integerValue]];
        [self updateCartButtonStatus];
    }
}

#pragma mark - Methods
- (void)updateCartCellWithMoreStatus:(BOOL)hasMore
{
    NSInteger currentNum = [self.countTextField.text integerValue];
    if (hasMore)
    {
        currentNum++;
    }
    else
    {
        currentNum--;
    }
    
    _num = currentNum;
    self.countTextField.text = [@(currentNum) stringValue];
}

- (void)updateCartButtonStatus
{
    NSInteger currentNum = [self.countTextField.text integerValue];

    self.lessButton.enabled = (currentNum > 1);
    self.moreButton.enabled = (currentNum < _maxNum);
}

- (void)createToolBarForTextField
{
    //代码创建 UIToolbar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.backgroundColor = [UIColor stec_toolBackgroundColor];
    
    toolbar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(0, 0, 40, 40);
    [doneBtn setTitleColor:[UIColor stec_redTextColor]
                  forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(completeButtonDidTappes)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    doneItem.tintColor = [UIColor stec_redTextColor];
    
    //toolbar属性设置
    toolbar.items = @[flexibleItem, doneItem];
    
    self.countTextField.inputAccessoryView = toolbar;
}

#pragma mark - Button Methods
- (void)completeButtonDidTappes
{
    [self endEditing:YES];
    
    NSInteger num = [self.countTextField.text integerValue];
    if (num > _maxNum || num <= 0)
    {
        if (self.cellDelegate
            && [self.cellDelegate respondsToSelector:@selector(cartShowMessage:)]
            && [self.cellDelegate respondsToSelector:@selector(cartNumberButtonDidTappedWithNumber:)])
        {
            _num = _maxNum;
            self.countTextField.text = [@(_maxNum) stringValue];

            [(id)self.cellDelegate cartNumberButtonDidTappedWithNumber:[self.countTextField.text integerValue]];
            [(id)self.cellDelegate cartShowMessage:@"数量超出范围~"];
            
            [self updateCartButtonStatus];
        }
    }
    else
    {
        if (self.cellDelegate
            && [self.cellDelegate respondsToSelector:@selector(cartNumberButtonDidTappedWithNumber:)])
        {
            _num = num;
            [(id)self.cellDelegate cartNumberButtonDidTappedWithNumber:[self.countTextField.text integerValue]];
            [self updateCartButtonStatus];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    BOOL canChange = [string isEqualToString:filtered];
    
    return canChange;
}

@end
