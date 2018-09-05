//
//  ESReturnBrandFooterView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnBrandFooterView.h"
#import "MBProgressHUD+NJ.h"

@implementation ESReturnBrandFooterView
{
    __weak IBOutlet UIButton *_selectAllBtn;
    __weak IBOutlet UILabel *_totalPriceLabel;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
}

- (void)updateBrandFooterView {
    if ([self.delegate respondsToSelector:@selector(isSelectedAll)]) {
        _selectAllBtn.selected = [self.delegate isSelectedAll];
    }
    if ([self.delegate respondsToSelector:@selector(getTotalPrice)]) {
        _totalPriceLabel.text = [self.delegate getTotalPrice];
    }
}

- (IBAction)selectAllBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(couldSelectAll)]) {
        if ([self.delegate couldSelectAll]) {
            sender.selected = !sender.selected;
        }
        if ([self.delegate respondsToSelector:@selector(selectAllItems:)]) {
            [self.delegate selectAllItems:sender.selected];
        }
    }

}
@end
