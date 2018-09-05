//
//  ESOrderListProductCell.m
//  Consumer
//
//  Created by jiang on 2017/7/4.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderListProductCell.h"
#import "UIImageView+WebCache.h"
#import "CoStringManager.h"

@interface ESOrderListProductCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnGoodsStatusLabel;

@end

@implementation ESOrderListProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _describLabel.textColor = [UIColor stec_contentTextColor];
    _describLabel.font = [UIFont stec_remarkTextFount];
    _numLabel.textColor = [UIColor stec_titleTextColor];
    _numLabel.font = [UIFont stec_remarkTextFount];
    _priceLabel.textColor = [UIColor stec_titleTextColor];
    _priceLabel.font = [UIFont stec_subTitleFount];
    _productImageView.clipsToBounds = YES;
    _productImageView.layer.cornerRadius = 2;
    
    
    _giftLabel.textColor = [UIColor stec_titleTextColor];
    _giftLabel.font = [UIFont stec_titleFount];

    
    // Initialization code
}

- (void)setProductInfo:(NSDictionary *)productInfo orderType:(NSString *)orderType {
    NSString *itemName = [NSString stringWithFormat:@"%@", [productInfo objectForKey:@"itemName"]];
    
    _titleLabel.text = [NSString stringWithFormat:@"%@",[CoStringManager displayCheckString:itemName]];
    NSArray *skuArr = productInfo[@"skuList"] ? productInfo[@"skuList"] : [NSArray array];
    NSMutableArray *skuValueArr = [NSMutableArray array];
    if ([skuArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in skuArr) {
            [skuValueArr addObject:dic[@"value"]];
        }
    }
    
    _describLabel.text = [skuValueArr componentsJoinedByString:@";"];
    if ([orderType isEqualToString:@"0"]) {
        _numLabel.text = [NSString stringWithFormat:@"可定制"];
    } else {
        _numLabel.text = [NSString stringWithFormat:@"×%@", productInfo[@"itemQuantity"] ? productInfo[@"itemQuantity"] : @"1"];
    }
    
    NSString *itemType = [NSString stringWithFormat:@"%@", [productInfo objectForKey:@"itemType"]];
    
    if ([itemType isEqualToString:@"1"]) {
        _giftLabel.text = [NSString stringWithFormat:@"赠品"];
    } else {
        _giftLabel.text = [NSString stringWithFormat:@""];
    }
    
    double itemPrice = [[NSString stringWithFormat:@"%@", ((productInfo[@"itemPrice"]!= [NSNull null]) ? productInfo[@"itemPrice"] : @"0.00")] doubleValue];
    
    NSString *itemPriceAccount = @"";
    if (itemPrice > 10000000.0) {
        itemPriceAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",itemPrice/10000.0]];
    } else {
        itemPriceAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",itemPrice]];
    }
    _priceLabel.text = [NSString stringWithFormat:@"￥%@",itemPriceAccount];
    
    
//    _priceLabel.text = [NSString stringWithFormat:@"￥%@",productInfo[@"itemPrice"] ? productInfo[@"itemPrice"] : @"0.00"];
    
    NSString *imgName = [NSString stringWithFormat:@"%@",productInfo[@"itemImg"] ? productInfo[@"itemImg"] : @""];
    if ([imgName hasPrefix:@"http"]) {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    } else {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
    }
    
    if (productInfo && [productInfo objectForKey:@"returnStatus"]) {
        NSInteger status = [[productInfo objectForKey:@"returnStatus"] integerValue];
        NSString *returnStatusStr = @"";
        switch (status) {
            case 1:
                //为退货
                returnStatusStr = @"";
                break;
            case 2:
                returnStatusStr = @"发生退款";
                break;
            case 3:
                returnStatusStr = @"退款完成";
                break;
            default:
                break;
        }
        self.returnGoodsStatusLabel.hidden = NO;
        self.returnGoodsStatusLabel.text = returnStatusStr;
    }else {
        self.returnGoodsStatusLabel.hidden = YES;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
