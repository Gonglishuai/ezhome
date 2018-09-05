//
//  ESPayWayFinanceCell.m
//  ESMall
//
//  Created by jiang on 2017/12/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESPayWayFinanceCell.h"
#import "Masonry.h"

@interface ESPayWayFinanceCell ()

@property (weak, nonatomic) IBOutlet UIImageView *payImageView;
@property (weak, nonatomic) IBOutlet UILabel *payTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *paySubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *openLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIView *payBackgroundView;

@end

@implementation ESPayWayFinanceCell
{
    NSIndexPath *_indexPath;
    NSString *_title;
    NSString *_subtitle;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _payTitleLabel.font = [UIFont stec_titleFount];
    _payTitleLabel.textColor = [UIColor stec_titleTextColor];
    _paySubTitleLabel.font = [UIFont stec_tagFount];
    _paySubTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    
    [self.payBackgroundView addGestureRecognizer:
     [[UITapGestureRecognizer alloc]
      initWithTarget:self
      action:@selector(paySelectedDidTapped:)]];
    WS(weakSelf)
    [_payBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(0);
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(0);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(0);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(0);
        make.height.greaterThanOrEqualTo(@(68));
    }];
    
}

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(getPayDataWithIndexPath:)]) {
        NSDictionary *dict = [(id)self.cellDelegate getPayDataWithIndexPath:indexPath];
        if (dict
            && [dict isKindOfClass:[NSDictionary class]])
        {
            _title = dict[@"title"];
            
            self.payImageView.image = [ESMallAssets bundleImage:dict[@"icon"]];//[UIImage imageNamed:dict[@"icon"]];
            self.payTitleLabel.text = dict[@"title"];
            self.selectedImageView.image = [UIImage imageNamed:dict[@"selectedIcon"]];
        }
    }
    
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(getFinanceStatusName)]) {
        NSString *statusName = [(id)self.cellDelegate getFinanceStatusName];
        _subtitle = statusName;
        self.paySubTitleLabel.text = statusName;
    }
    
}

#pragma mark - Tap Method
- (void)paySelectedDidTapped:(UITapGestureRecognizer *)tap
{
    if (self.cellDelegate
        && [self.cellDelegate respondsToSelector:@selector(paySelectedDidTapped:title:)])
    {
        [(id)self.cellDelegate paySelectedDidTapped:_indexPath
                                              title:_title];
    }
}
@end
