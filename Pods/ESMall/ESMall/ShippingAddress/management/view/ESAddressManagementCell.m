//
//  ESAddressManagementCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddressManagementCell.h"

@implementation ESAddressManagementCell
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_phoneLabel;
    __weak IBOutlet UILabel *_addrDetailLabel;
    __weak IBOutlet UIButton *_defaultBtn;
    __weak IBOutlet UIButton *_editBtn;
    __weak IBOutlet UIButton *_deleteBtn;
    
    NSInteger _currentIndex;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateAddrManagementCell:(NSInteger)index {
    _currentIndex = index;
    
    if ([self.delegate respondsToSelector:@selector(getAddressName:)]) {
        _nameLabel.text = [self.delegate getAddressName:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(getAddressPhone:)]) {
        _phoneLabel.text = [self.delegate getAddressPhone:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(getAddressDetail:)]) {
        _addrDetailLabel.text = [self.delegate getAddressDetail:index];
    }
    
    if ([self.delegate respondsToSelector:@selector(isDefaultAddress:)]) {
        UIImage *img = [UIImage imageNamed:[self.delegate isDefaultAddress:index] ? @"pay_way_select" : @"pay_way_unselect"];
        [_defaultBtn setImage:img forState:UIControlStateNormal];
    }
}

- (IBAction)defaultBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(setDefaultAddress:)]) {
        [self.delegate setDefaultAddress:_currentIndex];
    }
}

- (IBAction)editBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(editAddress:)]) {
        [self.delegate editAddress:_currentIndex];
    }
}

- (IBAction)deleteBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteAddress:)]) {
        [self.delegate deleteAddress:_currentIndex];
    }
}


@end
