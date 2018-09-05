//
//  ESReturnGoodsItemCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnGoodsItemCell.h"
#import "UIImageView+WebCache.h"
#import <ESFoundation/UIColor+Stec.h>

@implementation ESReturnGoodsItemCell
{
    __weak IBOutlet UIImageView *_itemImgView;
    __weak IBOutlet UILabel *_itemNameLabel;
    __weak IBOutlet UILabel *_itemPriceLabel;
    __weak IBOutlet UILabel *_itemCountLabel;
    __weak IBOutlet UILabel *_itemSKULabel;
    __weak IBOutlet UILabel *_returnPriceLabel;
    
    __weak IBOutlet NSLayoutConstraint *_topGrayViewLeftConstraint;
    __weak IBOutlet NSLayoutConstraint *_topGrayViewRightConstraint;
    __weak IBOutlet NSLayoutConstraint *_topGrayViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *_middileGrayViewHeightConstraint;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _itemImgView.layer.cornerRadius = 5;
    _itemImgView.layer.borderColor = [UIColor stec_viewBackgroundColor].CGColor;
    _itemImgView.layer.borderWidth = 1.0f;
}

- (void)updateItemCell:(NSInteger)index {
    _topGrayViewLeftConstraint.constant = index == 1 ? 0.0f : 15.0f;
    _topGrayViewRightConstraint.constant = index == 1 ? 0.0f : 15.0f;
    
    if ([self.delegate respondsToSelector:@selector(getItemImage:)]) {
        NSString *url = [self.delegate getItemImage:index];
        [_itemImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"RenduIsNUll"]];
    }
    if ([self.delegate respondsToSelector:@selector(getItemName:)]) {
        _itemNameLabel.text = [self.delegate getItemName:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemPrice:)]) {
        _itemPriceLabel.text = [self.delegate getItemPrice:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemQuantity:)]) {
        _itemCountLabel.text = [self.delegate getItemQuantity:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemSKU:)]) {
        _itemSKULabel.text = [self.delegate getItemSKU:index];
    }
    if ([self.delegate respondsToSelector:@selector(getReturnAmount:)]) {
        _returnPriceLabel.text = [self.delegate getReturnAmount:index];
    }
    _topGrayViewHeightConstraint.constant = 0.5f;
    _middileGrayViewHeightConstraint.constant = 0.5f;
}
@end
