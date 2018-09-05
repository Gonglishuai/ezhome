//
//  ESMSAddressCell.m
//  Consumer
//
//  Created by jiang on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMSAddressCell.h"
#import "ESAddress.h"

@interface ESMSAddressCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation ESMSAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = 0;
    
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _subTitleLabel.font = [UIFont stec_subTitleFount];
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle  {
    _titleLabel.text = title;
    _subTitleLabel.text = subTitle;
}

- (void)setMakeSureOrderAdress:(ESAddress *)addressInfo {
    NSString *province = addressInfo.province?addressInfo.province:@"";
    NSString *city = addressInfo.city?addressInfo.city:@"";
    NSString *district = addressInfo.district?addressInfo.district:@"";
    NSString *addressIn = addressInfo.addressInfo?addressInfo.addressInfo:@"";
    NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@", province, city, district, addressIn];
    
    [self setTitle:[NSString stringWithFormat:@"%@   %@", addressInfo.name, addressInfo.phone] subTitle:address];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
