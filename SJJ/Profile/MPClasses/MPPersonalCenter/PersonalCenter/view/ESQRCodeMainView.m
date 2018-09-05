//
//  ESQRCodeMainView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESQRCodeMainView.h"

@implementation ESQRCodeMainView
{
    __weak IBOutlet UIImageView *_qrImageView;
    __weak IBOutlet UIView *_whiteView;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    _whiteView.layer.cornerRadius = 13.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setQRImage:(UIImage *)image {
    [_qrImageView setImage:image];
}

- (IBAction)closeBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(closeBtnClick)]) {
        [self.delegate closeBtnClick];
    }
}

@end
