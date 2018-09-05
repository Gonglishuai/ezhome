//
//  ESPersonalCenterCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESPersonalCenterCell.h"

@implementation ESPersonalCenterCell
{
    __weak IBOutlet UIImageView *_itemIcon;
    __weak IBOutlet UILabel *_itemTitle;
    __weak IBOutlet UIView *_bottomLineView;
    __weak IBOutlet UILabel *_itemSubTitle;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _itemSubTitle.textColor = [UIColor stec_subTitleTextColor];
    _itemSubTitle.font = [UIFont stec_subTitleFount];
    _itemSubTitle.layer.borderWidth = 0;
    _itemSubTitle.layer.borderColor = [[UIColor clearColor] CGColor];
}

- (void)setBottomLine:(BOOL)visible {
    _bottomLineView.hidden = !visible;
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath {
    _itemSubTitle.layer.borderWidth = 0.00;
    _itemSubTitle.layer.borderColor = [[UIColor clearColor] CGColor];
    _itemSubTitle.textColor = [UIColor stec_subTitleTextColor];
    
    if ([self.delegate respondsToSelector:@selector(getItemIconWithIndexPath:)]) {
        NSString *imageName = [self.delegate getItemIconWithIndexPath:indexPath];
        [_itemIcon setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    }
    
    if ([self.delegate respondsToSelector:@selector(getItemTitleWithIndexPath:)]) {
        NSString *title = [self.delegate getItemTitleWithIndexPath:indexPath];
        _itemTitle.text = title;
    }
    _itemSubTitle.text = @"";
    if ([_itemTitle.text isEqualToString:@"我的钱包"]) {
        if ([self.delegate respondsToSelector:@selector(getMoneyNumber)]) {
            NSString *title = [self.delegate getMoneyNumber];
            _itemSubTitle.text = title;
        }
    } else if ([_itemTitle.text isEqualToString:@"居然分期"]) {
        NSString *title = @"";
        if ([self.delegate respondsToSelector:@selector(getFinanceNumber)]) {
            title = [self.delegate getFinanceNumber];
            _itemSubTitle.text = [NSString stringWithFormat:@" %@ ", title];
        }
        _itemSubTitle.layer.borderColor = [[UIColor clearColor] CGColor];
        if ([self.delegate respondsToSelector:@selector(getFinanceStatus)]) {
            NSString *status = [self.delegate getFinanceStatus];
            if (([status isEqualToString:@""] || [status isEqualToString:@"SQZT_NULL"]) && [title isEqualToString:@""]) {
                _itemSubTitle.textColor = [UIColor stec_greenStatusTextColor];
                _itemSubTitle.clipsToBounds = YES;
                _itemSubTitle.layer.borderWidth = 0.5;
                if ([title isEqualToString:@""] || (![title containsString:@"开通"])) {
                    _itemSubTitle.layer.borderWidth = 0.0;
                }
                _itemSubTitle.layer.cornerRadius = _itemSubTitle.frame.size.height/2;
                _itemSubTitle.layer.borderColor = [[UIColor stec_greenStatusTextColor] CGColor];
            } else if ([status isEqualToString:@"SQZT_TG"]) {
                _itemSubTitle.textColor = [UIColor stec_orangeTextColor];
                _itemSubTitle.clipsToBounds = YES;
                _itemSubTitle.layer.borderWidth = 0.5;
                if (![title containsString:@"激活"]) {
                    _itemSubTitle.layer.borderWidth = 0.0;
                }
                _itemSubTitle.layer.cornerRadius = _itemSubTitle.frame.size.height/2;
                _itemSubTitle.layer.borderColor = [[UIColor stec_orangeTextColor] CGColor];
            } else {
                _itemSubTitle.textColor = [UIColor stec_subTitleTextColor];
                _itemSubTitle.clipsToBounds = NO;
                _itemSubTitle.layer.borderWidth = 0;
                _itemSubTitle.layer.cornerRadius = 0;
                _itemSubTitle.layer.borderColor = [[UIColor stec_subTitleTextColor] CGColor];
            }
        }
    }
}

@end
