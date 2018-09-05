//
//  ESCaseProductListCollectionCell.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseProductListCollectionCell.h"
#import "UIImageView+WebCache.h"

@interface ESCaseProductListCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ESCaseProductListCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_remarkTextFount];
}

- (void)setDatas:(ESCaseProductModel *)prodtctInfo {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:prodtctInfo.skuName?prodtctInfo.skuName:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    _titleLabel.attributedText = attributedString;
    
    NSString *imgName = [NSString stringWithFormat:@"%@",prodtctInfo.imgUrl];
    if ([imgName hasPrefix:@"http"]) {
        [_productImgView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:ICON_EQUAL_DEFAULT]];
    } else {
        [_productImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
    _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}


@end
