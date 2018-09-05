//
//  ESOrderStatusCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderStatusCell.h"

@implementation ESOrderStatusCell
{
    __weak IBOutlet UIImageView *_backGroundImgView;
    __weak IBOutlet UILabel *_statusLabel;
    __weak IBOutlet UILabel *_detailLabel;
    __weak IBOutlet UILabel *_extendLabel;
    __weak IBOutlet NSLayoutConstraint *_statusLabelConstraintTop;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateStatusCell {
    if ([self.delegate respondsToSelector:@selector(getStatusBackImg)]) {
        [_backGroundImgView setImage:[UIImage imageNamed:[self.delegate getStatusBackImg]]];
    }
    if ([self.delegate respondsToSelector:@selector(getStatusTitle)]) {
        _statusLabel.text = [self.delegate getStatusTitle];
    }

    BOOL hasDetail = NO;
    if ([self.delegate respondsToSelector:@selector(getStatusDetail)]) {
        NSString *detail = [self.delegate getStatusDetail];
        hasDetail = detail && ![detail isEqualToString:@""];
        _detailLabel.text = detail;
    }
    
    CGFloat cellH = self.frame.size.height;
    CGFloat top = hasDetail ? (cellH - 24 - 7 -15) / 2 : (cellH - 24) / 2;
    _statusLabelConstraintTop.constant = top;
    _detailLabel.hidden = !hasDetail;

    BOOL hasExtend = NO;
    if ([self.delegate respondsToSelector:@selector(getStatusExtend)]) {
        NSString *extend = [self.delegate getStatusExtend];
        hasExtend = extend && ! [extend isEqualToString:@""];
        _extendLabel.text = extend;
    }
    _extendLabel.hidden = !hasExtend;
}

@end
