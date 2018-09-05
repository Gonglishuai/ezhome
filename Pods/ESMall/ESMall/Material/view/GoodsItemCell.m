//
//  GoodsItemCell.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "GoodsItemCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
@interface GoodsItemCell()
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UIImageView *couponImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *rebateTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *rebateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rebateNextLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@property (weak, nonatomic) IBOutlet UIView *tagBackgroundView;

@end

@implementation GoodsItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _nameLabel.textColor = [UIColor stec_titleTextColor];
    _nameLabel.font = [UIFont stec_subTitleFount];
    _nameLabel.numberOfLines = 2;
    
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _priceLabel.textColor = [UIColor stec_redTextColor];
    _priceLabel.font = [UIFont fontWithSize:15.0f];
    
    _goodImageView.clipsToBounds = YES;
    _goodImageView.layer.cornerRadius = 2;
    _goodImageView.layer.borderColor = [[UIColor stec_lineGrayColor] CGColor];
    _goodImageView.layer.borderWidth = 0.5;
    
    _rebateLabel.textColor = [UIColor whiteColor];
    _rebateLabel.font = [UIFont stec_remarkTextFount];
    _rebateLabel.clipsToBounds = YES;
    _rebateLabel.layer.cornerRadius = 1.5;
    
    _rebateTwoLabel.textColor = [UIColor whiteColor];
    _rebateTwoLabel.font = [UIFont stec_remarkTextFount];
    _rebateTwoLabel.clipsToBounds = YES;
    _rebateTwoLabel.layer.cornerRadius = 1.5;
    
    _rebateNextLabel.textColor = [UIColor whiteColor];
    _rebateNextLabel.font = [UIFont stec_remarkTextFount];
    _rebateNextLabel.clipsToBounds = YES;
    _rebateNextLabel.layer.cornerRadius = 1.5;
    
    
    _couponLabel.textColor = [UIColor whiteColor];
    _couponLabel.font = [UIFont boldSystemFontOfSize:13];
}

- (void)setProductInfo:(NSDictionary *)info {
    
    //    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"圣诞节卡仕达看见爱上大健康是的哈手机客服电话撒克己奉公上岛咖啡公司的风华绝代"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:info[@"name"]?info[@"name"]:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    _nameLabel.attributedText = attributedString;
    //    _priceLabel.text = [NSString stringWithFormat:@"￥%@", info[@"price"]?info[@"price"]:@"0.00"];
    
    double prices = [[NSString stringWithFormat:@"%@", (info[@"price"] ? info[@"price"] : @"0.00")] doubleValue];
    
    NSString *itemPriceAccount = @"";
    if (prices > 10000000.0) {
        itemPriceAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",prices/10000.0]];
    } else {
        itemPriceAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",prices]];
    }
    
    //    NSString *pricesAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",prices]];
    _priceLabel.text = [NSString stringWithFormat:@"¥%@", itemPriceAccount];
    
    NSString *priceOriginal = info[@"priceOriginal"];
    if ([priceOriginal isKindOfClass:[NSString class]]) {
        if ([priceOriginal isEqualToString:@""]) {
            self.originalPriceLabel.hidden = YES;
        } else {
            self.originalPriceLabel.hidden = NO;
            NSString *oldItemPriceAccount = oldItemPriceAccount = [NSString stringWithFormat:@"¥%@ ",priceOriginal];
            
            NSDictionary *attributes = @{
                                         NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                         NSStrikethroughColorAttributeName:[UIColor stec_contentTextColor]};
            NSAttributedString *attrStr =
            [[NSAttributedString alloc]initWithString:oldItemPriceAccount
                                           attributes:attributes];
            self.originalPriceLabel.attributedText = attrStr;
        }
        
    } else {
        self.originalPriceLabel.hidden = YES;
    }
    
    
    NSString *imgName = [NSString stringWithFormat:@"%@",info[@"image"] ? info[@"image"] : @""];
    if ([imgName hasPrefix:@"http"]) {
        [_goodImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    } else {
        [_goodImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    self.activityImageView.hidden = YES;
    if (info[@"actLogo"]
        && [info[@"actLogo"] isKindOfClass:[NSString class]])
    {
        NSString *actLogo = info[@"actLogo"];
        if (actLogo.length > 0)
        {
            self.activityImageView.hidden = NO;
            [self.activityImageView sd_setImageWithURL:[NSURL URLWithString:actLogo]];
        }
    }
    
    if ([info[@"offTag"] isKindOfClass:[NSString class]]) {
        NSString *coupon = [NSString stringWithFormat:@"%@ ",info[@"offTag"] ? info[@"offTag"] : @""];
        coupon = [coupon stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([coupon isEqualToString:@""]){
            _couponLabel.text = @"";
            _couponImgView.image = [UIImage imageNamed:@""];
        } else {
            _couponLabel.text = coupon;
            _couponImgView.image = [UIImage imageNamed:@"master_list_coupon"];
        }
    } else {
        _couponLabel.text = @"";
        _couponImgView.image = [UIImage imageNamed:@""];
    }
    
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.tagBackgroundView.hidden = YES;
    if (info[@"tags"]
        && [info[@"tags"] isKindOfClass:[NSArray class]])
    {
        NSArray *tags = info[@"tags"];
        self.tagBackgroundView.hidden = tags.count <= 0;
        for (UIView *view in [self.tagBackgroundView subviews])
        {
            [view removeFromSuperview];
        }
        
        CGFloat labelX = 0.0f;
        CGFloat labelY = 0.0;
        CGFloat widSpace = 6.0f;
        CGFloat heiSpace = 6.0f;
        // 商城首页给item的最大宽度
        CGFloat maxWidth = (SCREEN_WIDTH-41)/2;
        CGFloat strMaxHeight = 16.0f;
        for (NSInteger i = 0; i < tags.count; i++)
        {
            NSDictionary *dicTag = tags[i];
            CGFloat strWidth = [dicTag[@"width"] floatValue];
            
            if (labelX + strWidth >= maxWidth)
            {
                labelX = 0;
                labelY = labelY + heiSpace + strMaxHeight;
            }
            
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor stec_redBackgroundColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont stec_remarkTextFount];
            label.clipsToBounds = YES;
            label.layer.cornerRadius = 1.5;
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(labelX, labelY, strWidth, strMaxHeight);
            label.text = dicTag[@"tag"];
            [self.tagBackgroundView addSubview:label];
            
            labelX = labelX + strWidth + widSpace;
        }
    }
}

- (void)setProductListInfo:(NSDictionary *)info {
    
    //    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"圣诞节卡仕达看见爱上大健康是的哈手机客服电话撒克己奉公上岛咖啡公司的风华绝代"];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:info[@"name"]?info[@"name"]:@""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    _nameLabel.attributedText = attributedString;
    
    
    double prices = [[NSString stringWithFormat:@"%@", (info[@"prices"] ? info[@"prices"] : @"0.00")] doubleValue];
    
    NSString *itemPriceAccount = @"";
    if (prices > 10000000.0) {
        itemPriceAccount = [NSString stringWithFormat:@"¥%@万",[NSString stringWithFormat:@"%.2f",prices/10000.0]];
    } else {
        itemPriceAccount = [NSString stringWithFormat:@"¥%@",[NSString stringWithFormat:@"%.2f",prices]];
    }
    
    //    NSString *pricesAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",prices]];
    
    self.priceLabel.text = itemPriceAccount;
    
    double oldPrices = 0.00;
    
    NSNumber *priceOriginal = info[@"priceOriginal"];
    if ([priceOriginal isKindOfClass:[NSNumber class]]) {
        oldPrices = [priceOriginal doubleValue];
    }
    NSString *oldItemPriceAccount = @"";
    if (oldPrices > 0) {
        if (oldPrices > 10000000.0) {
            oldItemPriceAccount = [NSString stringWithFormat:@"¥%@万 ",[NSString stringWithFormat:@"%.2f",oldPrices/10000.0]];
        } else {
            oldItemPriceAccount = [NSString stringWithFormat:@"¥%@ ",[NSString stringWithFormat:@"%.2f",oldPrices]];
        }
    }
    
    NSDictionary *attributes = @{
                                 NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],
                                 NSStrikethroughColorAttributeName:[UIColor stec_contentTextColor]};
    NSAttributedString *attrStr =
    [[NSAttributedString alloc]initWithString:oldItemPriceAccount
                                   attributes:attributes];
    self.originalPriceLabel.attributedText = attrStr;
    
    if (oldPrices > 0 && oldPrices > prices) {
        self.originalPriceLabel.hidden = NO;
        
    }else {
        self.originalPriceLabel.hidden = YES;
    }
    
    NSString *imgName = [NSString stringWithFormat:@"%@",info[@"fullImage"] ? info[@"fullImage"] : @""];
    if ([imgName hasPrefix:@"http"]) {
        [_goodImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    } else {
        [_goodImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    self.activityImageView.hidden = YES;
    if (info[@"actLogo"]
        && [info[@"actLogo"] isKindOfClass:[NSString class]])
    {
        NSString *actLogo = info[@"actLogo"];
        if (actLogo.length > 0)
        {
            self.activityImageView.hidden = NO;
            [self.activityImageView sd_setImageWithURL:[NSURL URLWithString:actLogo]];
        }
    }
    
    if ([info[@"coupon"] isKindOfClass:[NSArray class]]) {
        NSArray *coupon = [NSArray arrayWithArray:info[@"coupon"]];
        if (coupon.count>0) {
            _couponLabel.hidden = NO;
            NSDictionary *dic = coupon[0];
            NSString *str = @"";
            if (dic.allKeys.count>0) {
                NSArray *titleArrr = [NSArray arrayWithArray:dic[@"list"]];
                if (titleArrr.count>0) {
                    str = [NSString stringWithFormat:@"%@", titleArrr[0]];
                }
            }
            _couponLabel.text = str;
            _couponImgView.image = [UIImage imageNamed:@"master_list_coupon"];
        } else {
            _couponLabel.text = @"";
            _couponImgView.image = [UIImage imageNamed:@""];
        }
        
    } else {
        _couponLabel.text = @"";
        _couponImgView.image = [UIImage imageNamed:@""];
    }
    
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.tagBackgroundView.hidden = YES;
    if (info[@"tags"]
        && [info[@"tags"] isKindOfClass:[NSArray class]])
    {
        NSArray *tags = info[@"tags"];
        self.tagBackgroundView.hidden = tags.count <= 0;
        for (UIView *view in [self.tagBackgroundView subviews])
        {
            [view removeFromSuperview];
        }
        
        CGFloat labelX = 0.0f;
        CGFloat labelY = 0.0;
        CGFloat widSpace = 6.0f;
        CGFloat heiSpace = 6.0f;
        // 商城首页给item的最大宽度
        CGFloat maxWidth = (SCREEN_WIDTH-41)/2;
        CGFloat strMaxHeight = 16.0f;
        for (NSInteger i = 0; i < tags.count; i++)
        {
            NSDictionary *dicTag = tags[i];
            CGFloat strWidth = [dicTag[@"width"] floatValue];
            
            if (labelX + strWidth >= maxWidth)
            {
                labelX = 0;
                labelY = labelY + heiSpace + strMaxHeight;
            }
            
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor stec_redBackgroundColor];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont stec_remarkTextFount];
            label.clipsToBounds = YES;
            label.layer.cornerRadius = 1.5;
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(labelX, labelY, strWidth, strMaxHeight);
            label.text = dicTag[@"tag"];
            [self.tagBackgroundView addSubview:label];
            
            labelX = labelX + strWidth + widSpace;
        }
    }
    
}

@end
