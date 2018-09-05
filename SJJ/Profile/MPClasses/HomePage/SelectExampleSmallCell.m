//
//  SelectExampleSmallCell.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SelectExampleSmallCell.h"
#import "HomeConsumerExampleModel.h"
#import "UIImageView+WebCache.h"

@interface SelectExampleSmallCell()
@property (weak, nonatomic) IBOutlet UIImageView *mainimgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic)HomeConsumerExampleModel *myModel;
@end

@implementation SelectExampleSmallCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _mainimgView.clipsToBounds = YES;
    _mainimgView.layer.cornerRadius = 2;
    _titleLabel.textColor = [UIColor stec_subTitleTextColor];
    _titleLabel.font = [UIFont stec_titleFount];
    // Initialization code
}

- (void)setModel:(HomeConsumerExampleModel *)model {
    _myModel = model;
    NSString *imgUrl = model.cover ? model.cover : @"";
    if ([imgUrl hasPrefix:@"http"]) {
        [_mainimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", imgUrl]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    } else {
        [_mainimgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgUrl]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
    
    NSString *style = model.style ? model.style : @"";
    NSString *type = model.house_type ? model.house_type : @"";
    NSString *areas = model.house_area ? model.house_area : @"";
    _titleLabel.text = [NSString stringWithFormat:@"%@ %@ %@", style, type, areas];
    
}

@end
