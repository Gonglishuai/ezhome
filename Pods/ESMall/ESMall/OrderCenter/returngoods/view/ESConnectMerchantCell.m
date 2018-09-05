//
//  ESConnectMerchantCell.m
//  Mall
//
//  Created by 焦旭 on 2017/9/15.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESConnectMerchantCell.h"

@implementation ESConnectMerchantCell
{
    __weak IBOutlet UIButton *_merchantNumberBtn;
    __weak IBOutlet UIImageView *_arrowRightImgView;
    NSInteger _section;
    NSInteger _index;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateCellWithSection:(NSInteger)section andIndex:(NSInteger)index {
    _section = section;
    _index = index;
    if ([self.delegate respondsToSelector:@selector(getMerchantNumberWithSection:andIndex:)]) {
        NSString *string = @"暂无商家电话";
        NSString *phone = [self.delegate getMerchantNumberWithSection:section andIndex:index];
        if (phone) {
            _merchantNumberBtn.enabled = YES;
            [_merchantNumberBtn setTitle:phone forState:UIControlStateNormal];
            [_merchantNumberBtn setTitleColor:[UIColor stec_lineBlueColor] forState:UIControlStateNormal];
        }else {
            _merchantNumberBtn.enabled = NO;
            [_merchantNumberBtn setTitle:string forState:UIControlStateNormal];
            [_merchantNumberBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)merchantNumberBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickMerchantNumberWithSection:andIndex:)]) {
        [self.delegate clickMerchantNumberWithSection:_section andIndex:_index];
    }
}

@end
