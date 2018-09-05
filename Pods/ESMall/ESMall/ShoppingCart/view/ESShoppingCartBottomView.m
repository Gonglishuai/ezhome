//
//  ESShoppingCartBottomView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartBottomView.h"
#import "ESCartInfo.h"

@interface ESShoppingCartBottomView()

@property (nonatomic, assign) ESCartConfirmButtonType type;

@end

@implementation ESShoppingCartBottomView
{
    __weak IBOutlet UIButton *_selectAllBtn;
    __weak IBOutlet UILabel *_totalTitleLabel;
    __weak IBOutlet UILabel *_totalPriceLabel;
    __weak IBOutlet UILabel *_orderAmountLabel;
    __weak IBOutlet UILabel *_discountAmountLabel;
    __weak IBOutlet UIButton *_settleBtn;
    
    __weak IBOutlet NSLayoutConstraint *_allLabelTopConstraint;
    __weak IBOutlet UILabel *_orderAmountTitleLabel;
    __weak IBOutlet UILabel *_discountAmountTitleLabel;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.type = ESCartConfirmButtonTypeSettleValid;
    
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _settleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
}

- (void)updateBottomView {
    if ([self.delegate respondsToSelector:@selector(hasEditingBrand)] &&
        self.type != ESCartConfirmButtonTypeDelete) {
        UIColor *color = [self.delegate hasEditingBrand] ? [UIColor stec_contentTextColor] : [UIColor stec_blueTextColor];
        [_settleBtn setBackgroundColor:color];
    }
    if ([self.delegate respondsToSelector:@selector(isSelected)]) {
        _selectAllBtn.selected = [self.delegate isSelected];
    }
    if ([self.delegate respondsToSelector:@selector(getTotalPrice)]) {
        ESCartInfo *info = [self.delegate getTotalPrice];
        if (info
            && [info isKindOfClass:[ESCartInfo class]])
        {
            _totalPriceLabel.text = [self getPriceStr:info.realAmount];
            BOOL discountStatus = info.discountAmount > 0;
            _orderAmountLabel.hidden = !discountStatus;
            _discountAmountLabel.hidden = !discountStatus;
            _orderAmountTitleLabel.hidden = !discountStatus;
            _discountAmountTitleLabel.hidden = !discountStatus;
            if (discountStatus)
            {
                _allLabelTopConstraint.constant = 9.0f;
                _orderAmountLabel.text = [self getPriceStr:info.orderAmount];
                _discountAmountLabel.text = [self getPriceStr:info.discountAmount];
            }
            else
            {
                _allLabelTopConstraint.constant = CGRectGetHeight(self.frame)/2.0f - CGRectGetHeight(_totalTitleLabel.frame)/2.0f;
            }
        }
    }
}

- (void)setRightBtn:(ESCartConfirmButtonType)type {
    self.type = type;
    _totalTitleLabel.hidden = NO;
    _totalPriceLabel.hidden = NO;
    UIColor *color = [UIColor stec_blueTextColor];
    NSString *title = @"结算";
    switch (type) {
        case ESCartConfirmButtonTypeSettleValid:
            color = [UIColor stec_blueTextColor];
            title = @"结算";
            break;
        case ESCartConfirmButtonTypeSettleInvalid:
            color = [UIColor stec_contentTextColor];
            title = @"结算";
            break;
        case ESCartConfirmButtonTypeDelete:
            color = [UIColor stec_deleteRowActionBackColor];
            title = @"删除";
            _totalTitleLabel.hidden = YES;
            _totalPriceLabel.hidden = YES;
            break;
        default:
            break;
    }
    [_settleBtn setBackgroundColor:color];
    [_settleBtn setTitle:title forState:UIControlStateNormal];
}

- (IBAction)selectAllBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(selectAllItems:callBack:)]) {
        sender.selected = !sender.selected;
        __weak UIButton *weakButton = sender;
        [self.delegate selectAllItems:sender.selected callBack:^(BOOL successStatus) {
            
            if (!successStatus)
            {
                weakButton.selected = !weakButton.selected;
            }
        }];
    }
}

- (IBAction)settleBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cartConfirmBtnClick:)]) {
        [self.delegate cartConfirmBtnClick:self.type];
    }
}

- (NSString *)getPriceStr:(double)price
{
    if (price > 10000000.0) {
        return [NSString stringWithFormat:@"¥ %.2f万", price/10000.0];
    }
    
    return [NSString stringWithFormat:@"¥ %.2f", price];
}

@end
