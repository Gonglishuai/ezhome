//
//  ESCooperativeBrandCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESCooperativeBrandCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESCooperativeBrandCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnLabel;

@end

@implementation ESCooperativeBrandCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _brandNameLabel.font = [UIFont stec_subTitleFount];
    _brandNameLabel.textColor = [UIColor stec_titleTextColor];
    
    _returnLabel.font = [UIFont stec_subTitleFount];
    _returnLabel.textColor = [UIColor stec_lineBlueColor];
    
    _brandImageView.layer.borderColor = [[UIColor stec_lineBorderColor] CGColor];
    _brandImageView.layer.borderWidth = 0.5;
    
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info {
    NSString *imageUrl = [NSString stringWithFormat:@"%@", info[@"brandLogo"] ? info[@"brandLogo"] : @""];
    if ([imageUrl hasPrefix:@"http"]) {
        [_brandImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    } else {
        [_brandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.imgHost, imageUrl]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    _brandNameLabel.text = [NSString stringWithFormat:@"%@", info[@"brandName"] ? info[@"brandName"] : @""];
    _returnLabel.text = [NSString stringWithFormat:@"%@", info[@"settle"] ? info[@"settle"] : @""];
}

@end
