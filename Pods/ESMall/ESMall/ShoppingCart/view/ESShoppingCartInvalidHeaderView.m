//
//  ESShoppingCartInvalidHeaderView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESShoppingCartInvalidHeaderView.h"

@implementation ESShoppingCartInvalidHeaderView
{
    __weak IBOutlet UILabel *_invalidTitleLabel;
    __weak IBOutlet UIButton *_clearBtn;
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
}

- (void)setInvalidTitle:(NSString *)title {
    _invalidTitleLabel.text = title;
}

- (IBAction)clearBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clearItemsWithSection:)]) {
        [self.delegate clearItemsWithSection:_section];
    }
}

@end
