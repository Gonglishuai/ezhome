//
//  ESPersonalActiveCell.m
//  Mall
//
//  Created by jiang on 2017/9/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPersonalActiveCell.h"
#import <Masonry.h>

@interface ESPersonalActiveCell()
@property (weak, nonatomic) IBOutlet UILabel *lineLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *goldnameLabel;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;

@end

@implementation ESPersonalActiveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _couponNumLabel.textColor = [UIColor stec_titleTextColor];
    _couponNumLabel.font = [UIFont boldSystemFontOfSize:14];
    
    _couponNameLabel.textColor = [UIColor stec_titleTextColor];
    _couponNameLabel.font = [UIFont stec_subTitleFount];
    
    _goldNumLabel.textColor = [UIColor stec_titleTextColor];
    _goldNumLabel.font = [UIFont boldSystemFontOfSize:14];
    
    _goldnameLabel.textColor = [UIColor stec_titleTextColor];
    _goldnameLabel.font = [UIFont stec_subTitleFount];
    
    _lineLabel.backgroundColor = [UIColor stec_lineGrayColor];
    
    // Initialization code
    [_view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(100));
    }];
    [_view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(100));
    }];
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(getCouponNumber)]) {
        NSString *couponNum = [self.delegate getCouponNumber];
        _couponNumLabel.text = couponNum;
    }
    
    if ([self.delegate respondsToSelector:@selector(getGoldNumber)]) {
        NSString *goldnum = [self.delegate getGoldNumber];
        _goldNumLabel.text = goldnum;
    }
}

- (IBAction)couponButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(isSelectCoupon:)]) {
        [self.delegate isSelectCoupon:YES];
    }
}
- (IBAction)goldButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(isSelectCoupon:)]) {
        [self.delegate isSelectCoupon:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
