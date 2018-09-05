//
//  ESReturnApplyItemCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnApplyItemCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NJ.h"
@implementation ESReturnApplyItemCell
{
    __weak IBOutlet UIButton *_selectBtn;
    __weak IBOutlet UIImageView *_itemImgView;
    __weak IBOutlet UILabel *_itemNameLabel;
    __weak IBOutlet UILabel *_itemSKULabel;
    __weak IBOutlet UILabel *_itemPriceLabel;
    __weak IBOutlet UILabel *_itemQuantityLabel;
    __weak IBOutlet UIView *_maskView;
    __weak IBOutlet UILabel *originalPriceLabel;
    __weak IBOutlet UIButton *minusButton;
    __weak IBOutlet UIButton *plusButton;
    __weak IBOutlet UILabel *returnApplyNumLabel;
    
    __weak IBOutlet UILabel *_giftStatusLabel;
    
    NSInteger _index;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _itemImgView.layer.cornerRadius = 2;
    _itemImgView.layer.borderColor = [UIColor stec_viewBackgroundColor].CGColor;
    _itemImgView.layer.borderWidth = 1.0f;
}

- (void)updateReturnApplyCellWithIndex:(NSInteger)index {
    _index = index;
    if ([self.delegate respondsToSelector:@selector(itemIsSelected:)]) {
        _selectBtn.selected = [self.delegate itemIsSelected:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemImage:)]) {
        NSString *url = [self.delegate getItemImage:index];
        [_itemImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"RenduIsNUll"]];
    }
    if ([self.delegate respondsToSelector:@selector(getItemName:)]) {
        _itemNameLabel.text = [self.delegate getItemName:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemSKUs:)]) {
        _itemSKULabel.text = [self.delegate getItemSKUs:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemPrice:)]) {
        _itemPriceLabel.text = [self.delegate getItemPrice:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemQuantity:)]) {
        _itemQuantityLabel.text = [self.delegate getItemQuantity:index];
    }
    if ([self.delegate respondsToSelector:@selector(itemIsValidWithIndex:)]) {
        _maskView.hidden = [self.delegate itemIsValidWithIndex:index];
        _maskView.alpha = [self.delegate itemIsValidWithIndex:index] ? 0 : 0.6;
    }
    if ([self.delegate respondsToSelector:@selector(getItemOriginalPrice:)]) {
        originalPriceLabel.text = [self.delegate getItemOriginalPrice:index];
    }
    if ([self.delegate respondsToSelector:@selector(minusBtnCanSelectWithIndex:)]) {
        BOOL able = [self.delegate minusBtnCanSelectWithIndex:index];
        [minusButton setEnabled:able];
    }
    if ([self.delegate respondsToSelector:@selector(plusBtnCanSelectWithIndex:)]) {
        BOOL able = [self.delegate plusBtnCanSelectWithIndex:index];
        [plusButton setEnabled:able];
    }
    if ([self.delegate respondsToSelector:@selector(getReturnApplyNum:)]) {
        NSString *numStr = [self.delegate getReturnApplyNum:index];
        returnApplyNumLabel.text = numStr;
    }
    if ([self.delegate respondsToSelector:@selector(getGiftStatusWithIndex:)]) {
        BOOL isGift = [self.delegate getGiftStatusWithIndex:index];
        _giftStatusLabel.hidden = !isGift;
        plusButton.hidden = isGift;
        minusButton.hidden = isGift;
        returnApplyNumLabel.hidden = isGift;
        _selectBtn.hidden = isGift;
    }
}

- (IBAction)selectBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(itemSelectedStatusWithIndex:)]) {
        BOOL status = [self.delegate itemSelectedStatusWithIndex:_index];
        if (status) {
            sender.selected = !sender.selected;
        }
        if ([self.delegate respondsToSelector:@selector(selectItem:withIndex:)]) {
            [self.delegate selectItem:sender.selected withIndex:_index];
        }
        
    }
}

- (IBAction)minusButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(minusBtnClickWithIndex:)]) {
        [self.delegate minusBtnClickWithIndex:_index];
    }
}

- (IBAction)plusButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(plusBtnClickWithIndex:)]) {
        [self.delegate plusBtnClickWithIndex:_index];
    }
}
@end
