//
//  ESRecommendDetailTopTableViewCell.m
//  Consumer
//
//  Created by jiang on 2018/1/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendDetailTopTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "JRNetEnvConfig.h"

@interface ESRecommendDetailTopTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightTopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *allImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *designerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *designerStyleLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end

@implementation ESRecommendDetailTopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _titleLabel.font = [UIFont stec_packageSubBigTitleFount];
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    
    _designerNameLabel.font = [UIFont stec_bigTitleFount];
    _designerNameLabel.textColor = [UIColor stec_subTitleTextColor];
    
    _designerStyleLabel.font = [UIFont stec_subTitleFount];
    _designerStyleLabel.textColor = [UIColor stec_contentTextColor];
    
    _describeLabel.font = [UIFont stec_titleFount];
    _describeLabel.textColor = [UIColor stec_subTitleTextColor];
    _headerImageView.layer.cornerRadius = 15;
    _headerImageView.clipsToBounds = YES;
    
    // Initialization code
}

- (void)setInfo:(NSDictionary *)info {
    _allImageView.hidden = YES;
    NSArray *list = info[@"productList"] ? info[@"productList"] : [NSArray array];
    NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"", @"", @"", nil];
    if ([list isKindOfClass:[NSArray class]]) {
        int i = 0;
        for (NSDictionary *dic in list) {
            NSString *url = [NSString stringWithFormat:@"%@", dic[@"image"]?dic[@"image"]:@""];
            [imgArray replaceObjectAtIndex:i withObject:url];
            i++;
            if (i>2) {
                break;
            }
        }
    }
    
    if ([imgArray[0] hasPrefix:@"http"]) {
        [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imgArray[0]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_leftImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgArray[0]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    if ([imgArray[1] hasPrefix:@"http"]) {
        [_rightTopImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imgArray[1]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_rightTopImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgArray[1]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    if ([imgArray[2] hasPrefix:@"http"]) {
        [_rightBottomImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imgArray[2]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_rightBottomImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgArray[2]]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    NSString *headerImgUrl = [NSString stringWithFormat:@"%@", info[@"avatar"] ? info[@"avatar"] : @""];
    if ([headerImgUrl hasPrefix:@"http"]) {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", headerImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, headerImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%@", info[@"name"] ? info[@"name"] : @""];
    _designerNameLabel.text = [NSString stringWithFormat:@"%@", info[@"designerName"] ? info[@"designerName"] : @""];
    _designerStyleLabel.text = [NSString stringWithFormat:@"%@  %@", (info[@"space"] ? info[@"space"] : @""), (info[@"style"] ? info[@"style"] : @"")];
    _describeLabel.text = [NSString stringWithFormat:@"%@", info[@"description"] ? info[@"description"] : @""];
}

- (void)setbrandInfo:(NSDictionary *)info {
    
    _leftImageView.hidden = YES;
    _rightTopImageView.hidden = YES;
    _rightBottomImageView.hidden = YES;
    NSArray *list = info[@"products"] ? info[@"products"] : [NSArray array];
    NSMutableArray *imgArray = [NSMutableArray arrayWithObjects:@"", @"", @"", nil];
    if ([list isKindOfClass:[NSArray class]]) {
        int i = 0;
        for (NSDictionary *dic in list) {
            NSString *url = [NSString stringWithFormat:@"%@", dic[@"image"]?dic[@"image"]:@""];
            [imgArray replaceObjectAtIndex:i withObject:url];
            i++;
            if (i>2) {
                break;
            }
        }
    }
    
    NSString *headerImgUrl = [NSString stringWithFormat:@"%@", info[@"avatar"] ? info[@"avatar"] : @""];
    if ([headerImgUrl hasPrefix:@"http"]) {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", headerImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    } else {
        [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, headerImgUrl]] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%@", info[@"name"] ? info[@"name"] : @""];
    _designerNameLabel.text = [NSString stringWithFormat:@"%@", info[@"designerName"] ? info[@"designerName"] : @""];
    _designerStyleLabel.text = [NSString stringWithFormat:@"%@  %@", (info[@"space"] ? info[@"space"] : @""), (info[@"style"] ? info[@"style"] : @"")];
    _describeLabel.text = [NSString stringWithFormat:@"%@", info[@"description"] ? info[@"description"] : @""];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
