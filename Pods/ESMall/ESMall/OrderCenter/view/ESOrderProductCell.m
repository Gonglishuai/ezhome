//
//  ESOrderProductCell.m
//  Consumer
//
//  Created by jiang on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderProductCell.h"
#import "UIImageView+WebCache.h"

@interface ESOrderProductCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *giftStatus;
@end

@implementation ESOrderProductCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _describLabel.textColor = [UIColor stec_contentTextColor];
    _describLabel.font = [UIFont stec_remarkTextFount];
    _numLabel.textColor = [UIColor stec_titleTextColor];
    _numLabel.font = [UIFont stec_remarkTextFount];
    _priceLabel.textColor = [UIColor stec_titleTextColor];
    _priceLabel.font = [UIFont stec_subTitleFount];
    _typeLabel.textColor = [UIColor stec_contentTextColor];
    _typeLabel.font = [UIFont stec_remarkTextFount];
    _typePriceLabel.textColor = [UIColor stec_titleTextColor];
    _typePriceLabel.font = [UIFont stec_remarkTextFount];
    _productImageView.clipsToBounds = YES;
    _productImageView.layer.cornerRadius = 2;
}

- (void)setProductInfo:(NSDictionary *)productInfo orderType:(NSString *)orderType isFromMakeSureController:(BOOL)isFromMakeSureController {
    
    /// 是否赠品
    _giftStatus.hidden = YES;
    if ([productInfo objectForKey:@"itemType"]
        && ![productInfo[@"itemType"] isKindOfClass:[NSNull class]])
    {
        _giftStatus.hidden = ![[productInfo objectForKey:@"itemType"] boolValue];
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%@", [productInfo objectForKey:@"itemName"]];
    
    NSString *imgName = [NSString stringWithFormat:@"%@",productInfo[@"itemImg"] ? productInfo[@"itemImg"] : @""];
    if ([imgName hasPrefix:@"http"]) {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:@"equal_default"]];
    } else {
        [_productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgName]] placeholderImage:[UIImage imageNamed:@"HouseDefaultImage"]];
    }
    
    NSArray *skuArr = productInfo[@"skuList"] ? productInfo[@"skuList"] : [NSArray array];
    NSMutableArray *skuValueArr = [NSMutableArray array];
    if ([skuArr isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dic in skuArr) {
            [skuValueArr addObject:dic[@"value"]];
        }
    }
    
    _describLabel.text = [skuValueArr componentsJoinedByString:@";"];
    
    double itemPrice = [[NSString stringWithFormat:@"%@", ((productInfo[@"itemPrice"]!= [NSNull null]) ? productInfo[@"itemPrice"] : @"0.00")] doubleValue];
    
    NSString *itemPriceAccount = @"";
    if (itemPrice > 10000000.0) {
        itemPriceAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",itemPrice/10000.0]];
    } else {
        itemPriceAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",itemPrice]];
    }
    _priceLabel.text = [NSString stringWithFormat:@"￥%@",itemPriceAccount];
    _numLabel.text = [NSString stringWithFormat:@"×%@", productInfo[@"itemQuantity"] ? productInfo[@"itemQuantity"] : @"1"];
    if ([orderType isEqualToString:@"0"]) {
        if (isFromMakeSureController) {
            _typeLabel.text = [NSString stringWithFormat:@"可定制"];
            _typePriceLabel.text = @"";
        } else {
            _typeLabel.text = [NSString stringWithFormat:@"定金"];
            
            NSString *payAmount = [NSString stringWithFormat:@"%@",productInfo[@"payAmount"] ? productInfo[@"payAmount"] : @"0.00"];
            double price = [payAmount doubleValue];
            NSString *itemPriceAccount = @"";
            if (price > 10000000.0) {
                itemPriceAccount = [NSString stringWithFormat:@"%@万",[NSString stringWithFormat:@"%.2f",price/10000.0]];
            } else {
                itemPriceAccount = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.2f",price]];
            }
            
            //        double pay = [[NSString stringWithFormat:@"%@", (productInfo[@"payAmount"] ? productInfo[@"payAmount"] : @"0.00")] doubleValue];
            //        NSString *factAccount = [NSString stringWithFormat:@"￥%@",[NSString stringWithFormat:@"%.2f",pay]];
            //
            _typePriceLabel.text = itemPriceAccount;//[NSString stringWithFormat:@"￥%@",productInfo[@"payAmount"] ? productInfo[@"payAmount"] : @"0.00"];
        }
        
    } else {
        _typeLabel.text = @"";
        _typePriceLabel.text = @"";
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
