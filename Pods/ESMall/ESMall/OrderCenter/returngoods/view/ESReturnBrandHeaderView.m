//
//  ESReturnBrandHeaderView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESReturnBrandHeaderView.h"

@implementation ESReturnBrandHeaderView
{
    __weak IBOutlet UILabel *_brandNameLabel;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView = ({
        UIView * view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor whiteColor];
        view;
    });
}

- (void)updateBrandHeaderView {
    if ([self.delegate respondsToSelector:@selector(getBrandName)]) {
        _brandNameLabel.text = [self.delegate getBrandName];
    }
}

@end
