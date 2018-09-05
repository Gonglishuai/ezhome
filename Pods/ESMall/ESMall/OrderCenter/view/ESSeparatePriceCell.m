//
//  ESSeparatePriceCell.m
//  Mall
//
//  Created by jiang on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESSeparatePriceCell.h"
#import <Masonry.h>

@interface ESSeparatePriceCell()
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end

@implementation ESSeparatePriceCell

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)awakeFromNib {
    [super awakeFromNib];
    // Drawing code
    _numberLabel.textColor = [UIColor stec_titleTextColor];
    _numberLabel.font = [UIFont stec_remarkTextFount];
    _priceLabel.textColor = [UIColor stec_redTextColor];
    _priceLabel.font = [UIFont stec_titleFount];
    
    _describeLabel.textColor = [UIColor stec_subTitleTextColor];
    _describeLabel.font = [UIFont stec_remarkTextFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle describeTitle:(NSString *)describeTitle {
    _numberLabel.text = title;
    _priceLabel.text = subTitle;
    _describeLabel.text = describeTitle;
    
    if (![subTitle isEqualToString:@""]) {
        _numberLabel.hidden = NO;
        _priceLabel.hidden = NO;
        
        [_priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(15.5);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-23);
            make.width.greaterThanOrEqualTo(@(42));
            make.height.equalTo(@(21));
        }];
        
        [_numberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_priceLabel.mas_centerY);
            make.trailing.equalTo(_priceLabel.mas_leading).with.offset(-8);
            make.width.greaterThanOrEqualTo(@(42));
            make.height.equalTo(@(21));
        }];
        
        [_describeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_priceLabel.mas_bottom).with.offset(8);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(23);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-23);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-13);
            make.height.equalTo(@(21));
        }];
    } else {
        _numberLabel.hidden = YES;
        _priceLabel.hidden = YES;
        [_describeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).with.offset(15.5);
            make.leading.equalTo(self.contentView.mas_leading).with.offset(23);
            make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-23);
            make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-13);
            make.height.equalTo(@(21));
        }];
    }
}

@end
