//
//  ESReAddressCell.m
//  demo
//
//  Created by shiyawei on 12/4/18.
//  Copyright © 2018年 hu. All rights reserved.
//

#import "ESRecAddressCell.h"
#import <Masonry.h>


#define cellHeight   50

@interface ESRecAddressCell ()
@property (nonatomic,strong)    UILabel *titleLabel;
@property (nonatomic,strong)    UILabel *subLabel;
@property (nonatomic,strong)    UIImageView *rightImgView;
@end

@implementation ESRecAddressCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        UIImage *img = [UIImage imageNamed:@"arrow_right"];
        [self addSubview:self.titleLabel];
        [self addSubview:self.rightImgView];
        [self addSubview:self.subLabel];
//        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left
//        }];
    }
    return self;
}

#pragma mark 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"地        址";
        _titleLabel.textColor = [UIColor blackColor];//#000000 100%
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.frame = CGRectMake(17, (cellHeight - 20) / 2, 60, 20);
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.textColor = ColorFromRGA(0xC7D1D6, 1.0);//#C7D1D6 100%
        _subLabel.text = @"请选择省市区";
        _subLabel.adjustsFontSizeToFitWidth = YES;
        _subLabel.font = [UIFont systemFontOfSize:14];
        UIImage *img = [UIImage imageNamed:@"arrow_right"];
        _subLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 36, self.titleLabel.frame.origin.y, SCREEN_WIDTH - 55 - img.size.width - CGRectGetMaxX(self.titleLabel.frame), self.titleLabel.frame.size.height);
    }
    return _subLabel;
}
- (UIImageView *)rightImgView {
    if (!_rightImgView) {
        _rightImgView = [[UIImageView alloc] init];
        UIImage *img = [UIImage imageNamed:@"arrow_right"];
        _rightImgView.image = img;
        _rightImgView.frame = CGRectMake(SCREEN_WIDTH - 15 - img.size.width, (cellHeight - img.size.height) / 2, img.size.width, img.size.height);
    }
    return _rightImgView;
}
    
- (void)setAddress:(NSString *)address {
    _address = address;
    self.subLabel.text = address;
    self.subLabel.textColor = [UIColor blackColor];
}
@end
