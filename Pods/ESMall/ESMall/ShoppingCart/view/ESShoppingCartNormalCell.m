//
//  ESShoppingCartNormalCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/3.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartNormalCell.h"
#import "UIImageView+WebCache.h"

@implementation ESShoppingCartNormalCell
{
    __weak IBOutlet UIButton *_selectBtn;
    __weak IBOutlet UIImageView *_itemImageView;
    __weak IBOutlet UILabel *_itemNameLabel;
    __weak IBOutlet UILabel *_itemSKULabel;
    __weak IBOutlet UILabel *_itemPriceLabel;
    __weak IBOutlet UILabel *_itemAmountLabel;
    __weak IBOutlet UILabel *_invalidLabel;
    __weak IBOutlet UIView *_maskView;
    
    __weak IBOutlet UIView *_promotionAllBackgroundView;
    __weak IBOutlet NSLayoutConstraint *_promotionAllBackgroundBottomConstraint;
    __weak IBOutlet UILabel *_promotionNameLabel;
    __weak IBOutlet UILabel *_promotionDescLabel;
    __weak IBOutlet UILabel *_giftsCountLabel;
    __weak IBOutlet UIImageView *_giftArrowStatus;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _invalidLabel.layer.cornerRadius = 2;
    _invalidLabel.hidden = YES;
    _itemImageView.layer.cornerRadius = 2;
    _itemImageView.layer.borderColor = [UIColor stec_viewBackgroundColor].CGColor;
    _itemImageView.layer.borderWidth = 0.5f;
    _itemImageView.layer.masksToBounds = YES;
    
    _promotionAllBackgroundView.layer.masksToBounds = YES;
    _promotionAllBackgroundBottomConstraint.constant = 0.0f;
    _promotionAllBackgroundView.layer.cornerRadius = 2.0f;
    _promotionAllBackgroundView.hidden = YES;
    
    [_promotionAllBackgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promotionDidTapped)]];
}

- (void)updateNormalCellWithSection:(NSInteger)section
                           andIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(isSelected:andIndex:)]) {
        _selectBtn.selected = [self.delegate isSelected:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemImage:andIndex:)]) {
        NSString *url = [self.delegate getItemImage:section andIndex:index];
        [_itemImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"shopping_cart_default"]];
    }
    if ([self.delegate respondsToSelector:@selector(getItemName:andIndex:)]) {
        _itemNameLabel.text = [self.delegate getItemName:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemSKU:andIndex:)]) {
        _itemSKULabel.text = [self.delegate getItemSKU:section andIndex:index];
    }
    if ([self.delegate respondsToSelector:@selector(getItemPrice:andIndex:)]) {
        _itemPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",[self.delegate getItemPrice:section andIndex:index]];
    }
    if ([self.delegate respondsToSelector:@selector(getItemAmount:andIndex:)]) {
        _itemAmountLabel.text = [NSString stringWithFormat:@"x %ld", (long)[self.delegate getItemAmount:section andIndex:index]];
    }
    
    if ([self.delegate respondsToSelector:@selector(getPromotionInfoWithSection:andIndex:)])
    {
        ESCartCommodityPromotion *promotionModel = [self.delegate getPromotionInfoWithSection:section andIndex:index];
        if (!promotionModel
            || ![promotionModel isKindOfClass:[ESCartCommodityPromotion class]])
        {
            _promotionAllBackgroundView.hidden = YES;
            _promotionAllBackgroundBottomConstraint.constant = 0.0f;
        }
        else
        {
            _promotionAllBackgroundView.hidden = NO;
            _promotionAllBackgroundBottomConstraint.constant = 14.5f;
            _promotionNameLabel.text = promotionModel.tagType;
            _promotionDescLabel.text = promotionModel.tagName;
            BOOL isGift = promotionModel.giftsCount > 0;
            _giftArrowStatus.hidden = !isGift;
            _giftsCountLabel.hidden = !isGift;
            if (isGift)
            {
                _giftArrowStatus.hidden = NO;
                if (promotionModel.rewardInfos
                    && [promotionModel.rewardInfos isKindOfClass:[NSArray class]]
                    && promotionModel.rewardInfos.count > 0)
                {
                    ESCartCommodityPromotionGift *giftModel = promotionModel.rewardInfos[0];
                    if (giftModel.objName
                        && [giftModel.objName isKindOfClass:[NSString class]]
                        && giftModel.objName.length > 0)
                    {
                        _promotionDescLabel.text = giftModel.objName;
                    }
                }
                _giftsCountLabel.text = [NSString stringWithFormat:@"x %ld", promotionModel.giftsCount];
            }
            else
            {
                _promotionDescLabel.text = promotionModel.tagName;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(getCommodityTyep:andIndex:)]) {
        ESCommodityType type = [self.delegate getCommodityTyep:section andIndex:index];
        switch (type) {
            case ESCommodityTypeValid: {
                [self setViewsValid:YES andSupport:YES];
                break;
            }
            case ESCommodityTypeNonsupport: {
                _promotionAllBackgroundView.hidden = YES;
                _promotionAllBackgroundBottomConstraint.constant = 0.0f;
                [self setViewsValid:YES andSupport:NO];
                break;
            }
            case ESCommodityTypeInvalid: {
                _promotionAllBackgroundView.hidden = YES;
                _promotionAllBackgroundBottomConstraint.constant = 0.0f;
                [self setViewsValid:NO andSupport:NO];
                break;
            }
            default:
                break;
        }
    }
}

- (void)deleteCellWithSection:(NSInteger)section
                     andIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(deleteItemWithSection:andIndex:)]) {
        [self.delegate deleteItemWithSection:section andIndex:index];
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

- (void)promotionDidTapped
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(promotionDidTappedWithSection:andIndex:)])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
        [self.delegate promotionDidTappedWithSection:indexPath.section andIndex:indexPath.row];
    }
}

- (void)setViewsValid:(BOOL)valid andSupport:(BOOL)support {
    _maskView.hidden = valid && support;
    _maskView.backgroundColor = [UIColor whiteColor];
    _maskView.alpha = 0.6;
    _selectBtn.hidden = !valid;
    _invalidLabel.hidden = valid;
}
@end
