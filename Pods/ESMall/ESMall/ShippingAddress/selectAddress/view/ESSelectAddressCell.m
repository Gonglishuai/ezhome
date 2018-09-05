//
//  ESSelectAddressCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESSelectAddressCell.h"

@implementation ESSelectAddressCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_defaultLogoLabel;
    __weak IBOutlet UILabel *_mobileLabel;
    __weak IBOutlet UILabel *_addrDetailLabel;
    __weak IBOutlet UIImageView *_selectedImgView;
    __weak IBOutlet UIView *_maskView;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _defaultLogoLabel.layer.cornerRadius = 10.0f;
    _defaultLogoLabel.layer.borderWidth = 1.0f;
    _defaultLogoLabel.layer.borderColor = ColorFromRGA(0x2696C4, 1).CGColor;
}

- (void)updateSelectAddrCellWithSection:(NSInteger)section andIndex:(NSInteger)index {
    
    _maskView.alpha = self.enabel ? 0 : 0.7;
    self.userInteractionEnabled = self.enabel;
    
    if ([self.delegate respondsToSelector:@selector(getAddressNameWithSection:andIndex:)]) {
        _nameLabel.text = [self.delegate getAddressNameWithSection:section andIndex:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(isDefaultAddressWithSection:andIndex:)]) {
        _defaultLogoLabel.hidden = ![self.delegate isDefaultAddressWithSection:section andIndex:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(getAddressPhoneWithSection:andIndex:)]) {
        _mobileLabel.text = [self.delegate getAddressPhoneWithSection:section andIndex:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(getAddressDetailWithSection:andIndex:)]) {
        _addrDetailLabel.text = [self.delegate getAddressDetailWithSection:section andIndex:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(isSelectedAddressWithSection:andIndex:)]) {
        BOOL isSelected = [self.delegate isSelectedAddressWithSection:section andIndex:index];
        UIImage *image = [UIImage imageNamed: isSelected ? @"pay_way_select" : @"pay_way_unselect"];
        [_selectedImgView setImage:image];
    }
}

@end
