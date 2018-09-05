//
//  DesignerView.m
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "DesignerView.h"
#import "HomeConsumerDesignerModel.h"
#import "UIImageView+WebCache.h"

@interface DesignerView()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *bigImgView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearFansLabel;
@property (weak, nonatomic) IBOutlet UILabel *styleLabel;
@property (strong, nonatomic) HomeConsumerDesignerModel *myModel;
@property (strong, nonatomic) NormalClickBlock myblock;

@end

@implementation DesignerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    _nameLabel.textColor = [UIColor stec_titleTextColor];
    _nameLabel.font = [UIFont stec_bigTitleFount];
    _yearFansLabel.textColor = [UIColor stec_subTitleTextColor];
    _yearFansLabel.font = [UIFont stec_subTitleFount];
    _styleLabel.textColor = [UIColor stec_subTitleTextColor];
    _styleLabel.font = [UIFont stec_subTitleFount];
    _bigImgView.clipsToBounds = YES;
    _bigImgView.layer.cornerRadius = 2;
    _smallImgView.clipsToBounds = YES;
    _smallImgView.layer.cornerRadius = _smallImgView.frame.size.width/2;
    UIColor* shadowColor = [UIColor blackColor];
    UIColor* shadow = [shadowColor colorWithAlphaComponent: 0.12];
    CGSize shadowOffset = CGSizeMake(2.0, 2.0);
    CGFloat shadowBlurRadius = 12/2.0;
    _backView.layer.shadowColor = [shadow CGColor];
    _backView.layer.shadowOpacity = 0.73;
    _backView.layer.shadowOffset = shadowOffset;
    _backView.layer.shadowRadius = shadowBlurRadius;
    _backView.layer.masksToBounds = NO;
    _backView.layer.cornerRadius = 3;
    
    
//    CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI_4);
//    [_smallImgView setTransform:transform];
//
//    _smallImgView.image = [UIImage imageWithCGImage:_smallImgView.image.CGImage scale:1 orientation:UIImageOrientationLeft];
}

- (void)setDataSource:(HomeConsumerDesignerModel *)model calculateBlock:(NormalClickBlock)block {
    _myblock = block;
    _myModel = model;
    NSString *imgUrl = _myModel.backgroundImage ? _myModel.backgroundImage : @"";
    if ([imgUrl hasPrefix:@"http"]) {
        [_bigImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    } else {
        [_bigImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [JRNetEnvConfig sharedInstance].netEnvModel.host, imgUrl]] placeholderImage:[UIImage imageNamed:HOUSE_DEFAULT_IMAGE]];
    }
    [_smallImgView sd_setImageWithURL:[NSURL URLWithString:_myModel.designer_avatar] placeholderImage:[UIImage imageNamed:ICON_HEADER_DEFAULT]];
    _nameLabel.text = _myModel.designer_name ? _myModel.designer_name : @"";
    
    NSString *year = _myModel.work_years ? _myModel.work_years : @"0";
//    NSString *fans = _myModel.attention_count ? _myModel.attention_count : @"0";
    NSString *style = _myModel.styles ? _myModel.styles : @"";
    _yearFansLabel.text = [NSString stringWithFormat:@"从业年限: %@年", year];
    _styleLabel.text = [NSString stringWithFormat:@"擅长风格: %@", style];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if (_myblock) {
        _myblock();
    }
}

@end
