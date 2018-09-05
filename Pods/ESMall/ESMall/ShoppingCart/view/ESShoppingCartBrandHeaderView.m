//
//  ESShoppingCartBrandHeaderView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartBrandHeaderView.h"

@implementation ESShoppingCartBrandHeaderView
{
    __weak IBOutlet UIButton *_selectBrandBtn;
    __weak IBOutlet UILabel *_brandNameLabel;
    __weak IBOutlet UIButton *_brandEditBtn;
    NSInteger _section;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor stec_viewBackgroundColor];
        view;
    });
}

- (void)updateHeaderView:(NSInteger)section {
    _section = section;
    if ([self.delegate respondsToSelector:@selector(isSelectBrandWithSection:)]) {
        _selectBrandBtn.selected = [self.delegate isSelectBrandWithSection:section];
    }
    if ([self.delegate respondsToSelector:@selector(getBrandNameWithSection:)]) {
        _brandNameLabel.text = [self.delegate getBrandNameWithSection:section];
    }
    if ([self.delegate respondsToSelector:@selector(isEditingWithSection:)]) {
        _brandEditBtn.selected = [self.delegate isEditingWithSection:section];
    }
    if ([self.delegate respondsToSelector:@selector(isEditAllStatus)]) {
        _brandEditBtn.hidden = [self.delegate isEditAllStatus];
    }
}

- (IBAction)selectBrandBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(selectBrandWithSection:callBack:)]) {
        sender.selected = !sender.selected;
        __weak UIButton *weakButton = sender;
        [self.delegate selectBrandWithSection:_section callBack:^(BOOL successStatus) {
            if(!successStatus)
            {
                weakButton.selected = !weakButton.selected;
            }
        }];
        
    }
    
}
- (IBAction)brandEditBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(editBrandWithSection:withStatus:)]) {
        [self.delegate editBrandWithSection:_section withStatus:!sender.selected];
    }
}
@end
