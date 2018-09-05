//
//  ESShoppingCartDeleteCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/3.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartDeleteCell.h"
#import "UIImageView+WebCache.h"

@implementation ESShoppingCartDeleteCell
{
    __weak IBOutlet UIButton *_selectBtn;
    __weak IBOutlet UIImageView *_itemImageView;
    __weak IBOutlet UIButton *_minusBtn;
    __weak IBOutlet UITextField *_amountTextField;
    __weak IBOutlet UIButton *_plusBtn;
    __weak IBOutlet UILabel *_skuLabel;
    __weak IBOutlet UIButton *_deleteBtn;
    __weak IBOutlet UIButton *_minusButton;
    __weak IBOutlet UIButton *_plusButton;
    __weak IBOutlet UIImageView *_arrowImageView;
    __weak IBOutlet UIView *_skuBackgroundView;
    
    NSInteger _minItemQuantity;
    NSInteger _maxItemQuantity;
    NSInteger _lastItemQuantity;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _itemImageView.layer.cornerRadius = 5;
    _itemImageView.layer.borderColor = [UIColor stec_viewBackgroundColor].CGColor;
    _itemImageView.layer.borderWidth = 1.0f;
    
    _arrowImageView.transform=CGAffineTransformMakeRotation(M_PI*0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSkuLabels)];
    [_skuBackgroundView addGestureRecognizer:tap];
    
    [self createToolBarForTextField];
}


- (void)updateDeleteCellWithSection:(NSInteger)section
                           andIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(isSelected:andIndex:)]) {
        _selectBtn.selected = [self.delegate isSelected:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemImage:andIndex:)]) {
        NSString *url = [self.delegate getItemImage:section andIndex:index];
        [_itemImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"shopping_cart_default"]];
    }
    if ([self.delegate respondsToSelector:@selector(getItemSKU:andIndex:)]) {
        _skuLabel.text = [self.delegate getItemSKU:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemAmount:andIndex:)]) {
        NSInteger num = [self.delegate getItemAmount:section andIndex:index];
        _amountTextField.text = [NSString stringWithFormat:@"%ld", (long)num];
    }
    if ([self.delegate respondsToSelector:@selector(getMinAmountWithSection:andIndex:)]) {
        _minItemQuantity = [self.delegate getMinAmountWithSection:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getMaxAmountWithSection:andIndex:)]) {
        _maxItemQuantity = [self.delegate getMaxAmountWithSection:section andIndex:index];
    }
    [self updateItemButtonsStatus];
}

- (void)chooseSkuLabels
{
    if ([self.delegate respondsToSelector:@selector(changeSkuAttribute:andIndex:)] && self.tableView) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
        [self.delegate changeSkuAttribute:indexPath.section andIndex:indexPath.row];
    }
}

- (IBAction)selectBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(selectItemWithSection:andIndex:callBack:)] && self.tableView) {
        sender.selected = !sender.selected;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
        __weak UIButton *weakButton = sender;
        [self.delegate selectItemWithSection:indexPath.section andIndex:indexPath.row callBack:^(BOOL successStatus)
        {
            if (!successStatus)
            {
                weakButton.selected = !weakButton.selected;
            }
        }];
    }
}

- (IBAction)minusBtnClick:(UIButton *)sender {
    NSInteger num = [_amountTextField.text integerValue];
    _lastItemQuantity = num;
    [self updateItemCount:--num];
}

- (IBAction)plusBtnClick:(UIButton *)sender {
    NSInteger num = [_amountTextField.text integerValue];
    _lastItemQuantity = num;
    [self updateItemCount:++num];
}

- (void)updateItemCount:(NSInteger)count
{
    NSInteger newCount = count;
    if (newCount < _minItemQuantity)
    {
        newCount = _minItemQuantity;
    }
    else if (newCount > _maxItemQuantity)
    {
        newCount = _maxItemQuantity;
    }
    
    if (newCount != count)
    {
//        if ([self.delegate respondsToSelector:@selector(showMessage:)]) {
//            [self.delegate showMessage:@"数量超出范围~"];
//        }
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if ([self.delegate respondsToSelector:@selector(updateItemCount:withSection:andIndex:callback:)]) {
        __weak UITextField *weakTF = _amountTextField;;
        [self.delegate updateItemCount:newCount withSection:indexPath.section andIndex:indexPath.row callback:^(BOOL successStatus)
        {// 回调
            if (!successStatus)
            {
                weakTF.text = [@(_lastItemQuantity) stringValue];
            }
        }];
    }
}

- (void)updateItemButtonsStatus
{
    NSInteger num = [_amountTextField.text integerValue];
    _minusBtn.enabled = num > _minItemQuantity;
    _plusBtn.enabled = num < _maxItemQuantity;
}

- (IBAction)deleteBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteItemWithSection:andIndex:)] && self.tableView) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
        [self.delegate deleteItemWithSection:indexPath.section andIndex:indexPath.row];
    }
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
    
    _amountTextField.inputAccessoryView = toolbar;
}

#pragma mark - Button Methods
- (void)completeButtonDidTappes
{
    SHLog(@"键盘完成按钮被点击");
    [self.contentView endEditing:YES];
    
    [self textInputDidChange];
}

- (void)textInputDidChange
{
    NSInteger num = [_amountTextField.text integerValue];
    [self updateItemCount:num];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _lastItemQuantity = [textField.text integerValue];
}

@end
