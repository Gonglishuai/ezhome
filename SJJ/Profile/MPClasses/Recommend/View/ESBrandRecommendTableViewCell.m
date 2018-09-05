//
//  ESBrandRecommendTableViewCell.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESBrandRecommendTableViewCell.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESBrandRecommendTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *productImageView1;
@property (weak, nonatomic) IBOutlet UIButton *productImageView2;
@property (weak, nonatomic) IBOutlet UIButton *productImageView3;
@property (weak, nonatomic) IBOutlet UIButton *productImageView4;
@property (weak, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeReasonLabel;
@property (strong, nonatomic) NSMutableArray *productIdArray;
@property (strong, nonatomic) void(^myProductBlock)(NSString *productId);
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@end

@implementation ESBrandRecommendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _brandNameLabel.font = [UIFont stec_titleFount];
    _brandNameLabel.textColor = [UIColor stec_titleTextColor];

    _describeReasonLabel.font = [UIFont stec_titleFount];
    _describeReasonLabel.textColor = [UIColor stec_contentTextColor];
    
    _noDataLabel.font = [UIFont stec_titleFount];
    _noDataLabel.textColor = [UIColor stec_titleTextColor];
//    _productImageView1.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _productImageView1.imageView.clipsToBounds = YES;
//    _productImageView2.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _productImageView2.imageView.clipsToBounds = YES;
//    _productImageView3.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _productImageView3.imageView.clipsToBounds = YES;
//    _productImageView4.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    _productImageView4.imageView.clipsToBounds = YES;
    
}

- (void)setInfo:(NSDictionary *)info productBlock:(void(^)(NSString *productId))productBlock {
    _myProductBlock = productBlock;
    
    NSString *imageUrl = [NSString stringWithFormat:@"%@", info[@"brandLogo"] ? info[@"brandLogo"] : @""];
    if ([imageUrl hasPrefix:@"http"]) {
        [_brandImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_brandImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imageUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    _brandNameLabel.text = [NSString stringWithFormat:@"%@", info[@"brandName"] ? info[@"brandName"] : @""];
    
    NSString *description = @"暂未填写推荐理由";
    if (info[@"description"] && ![info[@"description"] isKindOfClass:[NSNull class]]) {
        description = [NSString stringWithFormat:@"%@", info[@"description"] ? info[@"description"] : @""];
    }
    _describeReasonLabel.text = [NSString stringWithFormat:@"推荐理由: %@", description];
    
    _productIdArray = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    NSArray *list = info[@"products"] ? info[@"products"] : [NSArray array];
    NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    if ([list isKindOfClass:[NSArray class]]) {
        int i = 0;
        for (NSDictionary *dic in list) {
            NSString *url = [NSString stringWithFormat:@"%@", dic[@"image"]?dic[@"image"]:@""];
            [imgArray replaceObjectAtIndex:i withObject:url];
            
            NSString *productId = [NSString stringWithFormat:@"%@", dic[@"spu"]?dic[@"spu"]:@""];
            [_productIdArray replaceObjectAtIndex:i withObject:productId];
            i++;
            if (i>3) {
                break;
            }
        }
    }
    NSString *nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[0]];
    if (![nextImgUrl hasPrefix:@"http"]) {
        nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
    }
    _noDataLabel.hidden = YES;
    _productImageView1.hidden = NO;
    if ([imgArray[0] isEqualToString:@""]) {
        _noDataLabel.hidden = NO;
        _productImageView1.hidden = YES;
    } else {
        [_productImageView1 sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    _productImageView2.hidden = NO;
    if ([imgArray[1] isEqualToString:@""]) {
        _productImageView2.hidden = YES;
    } else {
        nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[1]];
        if (![nextImgUrl hasPrefix:@"http"]) {
            nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
        }
        [_productImageView2 sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    _productImageView3.hidden = NO;
    if ([imgArray[2] isEqualToString:@""]) {
        _productImageView3.hidden = YES;
    } else {
        nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[2]];
        if (![nextImgUrl hasPrefix:@"http"]) {
            nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
        }
        [_productImageView3 sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
    
    _productImageView4.hidden = NO;
    if ([imgArray[3] isEqualToString:@""]) {
        _productImageView4.hidden = YES;
    } else {
        nextImgUrl = [NSString stringWithFormat:@"%@", imgArray[3]];
        if (![nextImgUrl hasPrefix:@"http"]) {
            nextImgUrl = [NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, nextImgUrl];
        }
        [_productImageView4 sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", nextImgUrl]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"equal_default"]];
    }
}

- (IBAction)buttonClicked1:(UIButton *)sender {
    if (_myProductBlock) {
        NSString *productId = [NSString stringWithFormat:@"%@", _productIdArray[0]];
        _myProductBlock(productId);
    }
}

- (IBAction)buttonClicked2:(UIButton *)sender {
    if (_myProductBlock) {
        NSString *productId = [NSString stringWithFormat:@"%@", _productIdArray[1]];
        _myProductBlock(productId);
    }
}
- (IBAction)buttonClicked3:(UIButton *)sender {
    if (_myProductBlock) {
        NSString *productId = [NSString stringWithFormat:@"%@", _productIdArray[2]];
        _myProductBlock(productId);
    }
}
- (IBAction)buttonClicked4:(UIButton *)sender {
    if (_myProductBlock) {
        NSString *productId = [NSString stringWithFormat:@"%@", _productIdArray[3]];
        _myProductBlock(productId);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
