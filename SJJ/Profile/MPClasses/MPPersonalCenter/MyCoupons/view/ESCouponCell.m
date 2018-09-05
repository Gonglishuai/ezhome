//
//  ESCouponCell.m
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCouponCell.h"
@interface ESCouponCell()
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (strong, nonatomic) void(^myblock)(void);

@end

@implementation ESCouponCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)ruleButtonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

- (void)setStatus:(CouponStatus)status info:(NSDictionary *)info block:(void(^)(void))block; {
    _myblock = block;
    switch (status) {
        case CouponStatusUnUse:
            _backImageView.image = [UIImage imageNamed:@"coupon"];
            _iconImageView.image = [UIImage imageNamed:@""];
            break;
        case CouponStatusUsed:
            _backImageView.image = [UIImage imageNamed:@"coupon_unable"];
            _iconImageView.image = [UIImage imageNamed:@"coupon_up_used"];
            break;
        case CouponStatusOverdue:
            _backImageView.image = [UIImage imageNamed:@"coupon_unable"];
            _iconImageView.image = [UIImage imageNamed:@"coupon_up_overdue"];
            break;
        case CouponStatusAbleUse:
            _backImageView.image = [UIImage imageNamed:@"coupon"];
            _iconImageView.image = [UIImage imageNamed:@""];
            break;
        case CouponStatusUnableUse:
            _backImageView.image = [UIImage imageNamed:@"coupon_unable"];
            _iconImageView.image = [UIImage imageNamed:@"coupon_up_unable"];
            break;
        
        case CouponStatusSelect:
            _backImageView.image = [UIImage imageNamed:@"coupon"];
            _iconImageView.image = [UIImage imageNamed:@"coupon_up_choose"];
            break;
            
        default:
            break;
    }
    NSMutableArray *timeArr = [NSMutableArray array];
    if ([info[@"startDate"] isKindOfClass:[NSString class]]) {
        [timeArr addObject:info[@"startDate"]?info[@"startDate"]:@""];
    }
    
    if ([info[@"endDate"] isKindOfClass:[NSString class]]) {
        [timeArr addObject:info[@"endDate"]?info[@"endDate"]:@""];
    }
    _timelabel.text = [NSString stringWithFormat:@"有效期:%@", [timeArr componentsJoinedByString:@"-"]];
    
    
    NSString *typeName = [NSString stringWithFormat:@"%@", info[@"typeName"]?info[@"typeName"]:@""];
    NSString *typeDesc = [NSString stringWithFormat:@"%@", info[@"typeDesc"]?info[@"typeDesc"]:@""];
    
    _couponNameLabel.text = typeName;
    _couponTypeLabel.text = typeDesc;
    
    
    NSString *price = [NSString stringWithFormat:@"%@", info[@"discountAmount"]?info[@"discountAmount"]:@""];
    NSString *discountInfo = [NSString stringWithFormat:@"%@", info[@"discountInfo"]?info[@"discountInfo"]:@""];
    
    NSMutableAttributedString *attributedPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", price, discountInfo]];
    [attributedPrice addAttributes:@{
                                     NSForegroundColorAttributeName: [UIColor whiteColor],
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:14]
                                     }
                             range:NSMakeRange(price.length, discountInfo.length+1)];
    
    _priceLabel.attributedText = attributedPrice;
    _couponNumLabel.text = [NSString stringWithFormat:@"券码:%@", info[@"code"]?info[@"code"]:@""];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
