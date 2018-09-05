//
//  ESCaseProductCollectionViewCell.m
//  Consumer
//
//  Created by jiang on 2017/8/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseProductCollectionViewCell.h"
#import "ESCaseProductModel.h"
#import "UIImageView+WebCache.h"

@interface ESCaseProductCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation ESCaseProductCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _nameLabel.textColor = [UIColor stec_titleTextColor];
    _nameLabel.font = [UIFont stec_remarkTextFount];
}
- (void)setFavDatas:(ESCaseProductModel *)prodtctInfo {
    NSString *imgName = [NSString stringWithFormat:@"%@",prodtctInfo.imgUrl];
    if ([imgName hasPrefix:@"http"]) {
        [_productImgView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:ICON_EQUAL_DEFAULT]];
    } else {
        [_productImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:prodtctInfo.skuName?prodtctInfo.skuName:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    _nameLabel.attributedText = attributedString;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

@end
