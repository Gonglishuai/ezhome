//
//  ESClickCell.m
//  Consumer
//
//  Created by jiang on 2017/6/26.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESClickCell.h"

@interface ESClickCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation ESClickCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _titleLabel.textColor = [UIColor stec_titleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    _subTitleLabel.textColor = [UIColor stec_redTextColor];
    _subTitleLabel.font = [UIFont stec_titleFount];
    // Initialization code
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle subTitleColor:(UIColor *)subtitleColor {
    if (subtitleColor) {
        _subTitleLabel.textColor = subtitleColor;
        _titleLabel.text = title;
        _subTitleLabel.text = subTitle;
    }
}

- (void)setInvoiceData:(NSIndexPath*)indexPath invoiceArray:(NSMutableArray *)invoiceArray {
    NSMutableDictionary *invoiceDic = [NSMutableDictionary dictionary];
    if (invoiceArray.count > indexPath.section-1) {
        invoiceDic = invoiceArray[indexPath.section-1];
    }
    NSString *subTitle = @"不开具发票";
    if (invoiceDic.allKeys.count>0) {
        NSString *invoiceHeadType = [NSString stringWithFormat:@"%@", [invoiceDic objectForKey:@"invoiceHeadType"]];
        if ([invoiceHeadType isEqualToString:@"0"]) {
            subTitle = @"纸质发票 个人";
        } else {
            NSString *invoiceType = [NSString stringWithFormat:@"%@", [invoiceDic objectForKey:@"invoiceType"]];
            if ([invoiceType isEqualToString:@"2"]) {
                subTitle = @"纸质发票 单位 专票";
            } else {
                subTitle = @"纸质发票 单位 普票";
            }
        }
    }
    _titleLabel.text = @"是否需要发票:";
    _subTitleLabel.textColor = [UIColor stec_subTitleTextColor];
    _subTitleLabel.text = subTitle;
}

- (void)setCouponData:(NSIndexPath *)indexPath couponArray:(NSMutableArray *)couponArray {
    NSMutableDictionary *couponDic = [NSMutableDictionary dictionary];
    if (couponArray.count > indexPath.section-1) {
        couponDic = couponArray[indexPath.section-1];
    }
    NSString *subTitle = @"未使用优惠券";
    if (couponDic.allKeys.count>0) {
        NSString *couponName = [NSString stringWithFormat:@"%@", [couponDic objectForKey:@"showContent"] ? [couponDic objectForKey:@"showContent"] : @""];
        if (![couponName isEqualToString:@""]) {
            subTitle = couponName;
        }
    }
    [self setTitle:@"优惠券:" subTitle:subTitle subTitleColor:[UIColor stec_subTitleTextColor]];
}

- (void)setServeShopData:(NSIndexPath *)indexPath selectServerStoreArray:(NSMutableArray *)selectServerStoreArray{
    NSMutableDictionary *serverStoreDic = [NSMutableDictionary dictionary];
    if (selectServerStoreArray.count > indexPath.section-1) {
        serverStoreDic = selectServerStoreArray[indexPath.section-1];
    }
    NSString *subTitle = @"请选择服务门店";
    if (serverStoreDic.allKeys.count > 0) {
        NSString *serverStoreName = [NSString stringWithFormat:@"%@", [serverStoreDic objectForKey:@"storeName"] ? [serverStoreDic objectForKey:@"storeName"] : @""];
        if (![serverStoreName isEqualToString:@""]) {
            subTitle = serverStoreName;
        }
    }
    [self setTitle:@"服务门店:" subTitle:subTitle subTitleColor:[UIColor stec_subTitleTextColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
