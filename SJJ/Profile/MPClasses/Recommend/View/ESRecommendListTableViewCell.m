//
//  ESRecommendListTableViewCell.m
//  Consumer
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendListTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESRecommendListTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightTopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBottomImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation ESRecommendListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.font = [UIFont stec_bigTitleFount];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    
    _subTitleLabel.font = [UIFont stec_remarkTextFount];
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    
    _dateLabel.font = [UIFont stec_remarkTextFount];
    _dateLabel.textColor = [UIColor stec_contentTextColor];
    
    _leftImageView.layer.borderColor = [[UIColor stec_lineBorderColor] CGColor];
    _leftImageView.layer.borderWidth = 0.5;
    _rightTopImageView.layer.borderColor = [[UIColor stec_lineBorderColor] CGColor];
    _rightTopImageView.layer.borderWidth = 0.5;
    _rightBottomImageView.layer.borderColor = [[UIColor stec_lineBorderColor] CGColor];
    _rightBottomImageView.layer.borderWidth = 0.5;
}

- (void)setInfo:(NSDictionary *)info isBrand:(BOOL)isBrand {
    if (isBrand) {
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightTopImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightBottomImageView.contentMode = UIViewContentModeScaleAspectFit;
        NSArray *list = info[@"brandList"] ? info[@"brandList"] : [NSArray array];
        NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"", @"", @"", nil];
        if ([list isKindOfClass:[NSArray class]]) {
            int i = 0;
            for (NSDictionary *dic in list) {
                NSString *url = [NSString stringWithFormat:@"%@", dic[@"brandLogo"]?dic[@"brandLogo"]:@""];
                [imgArray replaceObjectAtIndex:i withObject:url];
                i++;
            }
        }
        
        NSString *nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[0]];
        if (![nextImgUrl hasPrefix:@"http"]) {
            nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
        }
        [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
        
        if (![imgArray[1] isEqualToString:@""]) {
            nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[1]];
            if (![nextImgUrl hasPrefix:@"http"]) {
                nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
            }
        }
        [_rightTopImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        
        if (![imgArray[2] isEqualToString:@""]) {
            nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[2]];
            if (![nextImgUrl hasPrefix:@"http"]) {
                nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
            }
        }
        [_rightBottomImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        
        _titleLabel.text = [NSString stringWithFormat:@"%@", info[@"name"] ? info[@"name"] : @""];
        _subTitleLabel.text = [NSString stringWithFormat:@"共%@个品牌", info[@"totalBrandCount"] ? info[@"totalBrandCount"] : @""];
        _dateLabel.text = [NSString stringWithFormat:@"%@", info[@"lastUpdateTime"] ? info[@"lastUpdateTime"] : @""];
    } else {
        NSArray *list = info[@"productList"] ? info[@"productList"] : [NSArray array];
        NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"", @"", @"", nil];
        if ([list isKindOfClass:[NSArray class]]) {
            int i = 0;
            for (NSDictionary *dic in list) {
                NSString *url = [NSString stringWithFormat:@"%@", dic[@"image"]?dic[@"image"]:@""];
                [imgArray replaceObjectAtIndex:i withObject:url];
                i++;
            }
        }
        
        NSString *nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[0]];
        if (![nextImgUrl hasPrefix:@"http"]) {
            nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
        }
        [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
        
        if (![imgArray[1] isEqualToString:@""]) {
            nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[1]];
            if (![nextImgUrl hasPrefix:@"http"]) {
                nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
            }
        }
        [_rightTopImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        
        if (![imgArray[2] isEqualToString:@""]) {
            nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[2]];
            if (![nextImgUrl hasPrefix:@"http"]) {
                nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
            }
        }
        [_rightBottomImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        
        _titleLabel.text = [NSString stringWithFormat:@"%@", info[@"name"] ? info[@"name"] : @""];
        _subTitleLabel.text = [NSString stringWithFormat:@"共%@件商品", info[@"itemCount"] ? info[@"itemCount"] : @""];
        _dateLabel.text = [NSString stringWithFormat:@"%@", info[@"lastUpdateTime"] ? info[@"lastUpdateTime"] : @""];
    }
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
