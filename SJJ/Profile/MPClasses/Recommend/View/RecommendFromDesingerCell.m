//
//  RecommendFromDesingerCell.m
//  Consumer
//
//  Created by shejijia on 13/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//


#import "RecommendFromDesingerCell.h"
#import "UIImageView+WebCache.h"
#import "ESRecommendRecordMemberModel.h"
#import <Masonry.h>


@implementation RecommendFromDesingerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configUI];
    }
    return  self;
}

//设置设计师推荐的信息

- (void)setInfo:(ESRecommendRecordMemberModel *)model{
    
    NSInteger listID = model.sourceType;
    if (listID == 10) {
        self.recommendTypeImV.image = [UIImage imageNamed:@"annli"];
    }else if(listID == 20){
        self.recommendTypeImV.image = [UIImage imageNamed:@"shangpin"];
    }else if(listID == 30){
        self.recommendTypeImV.image = [UIImage imageNamed:@"pinpai"];
    }else{
        self.recommendTypeImV.image =[UIImage imageNamed:@"defaultPlaceholder"];
    }
    if ([model.preview isEqual:[NSNull null]]) {
        self.backImgV.image =[UIImage imageNamed:@"defaultPlaceholder"];
    }else{
        NSString *imageUrl = model.preview;
        [self.backImgV sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    }

    NSString *iconImgUrl = model.avatar;
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:iconImgUrl] placeholderImage:[UIImage imageNamed:@"defaultPlaceholder"]];
    self.title.text = model.inventoryName;
    self.name.text = model.name;
    self.recommendTime.text = model.time;
    self.recommendTime.text = [NSString stringWithFormat:@"%@推荐",self.recommendTime.text];
}

- (void)configUI{
    
    [self addSubview:self.backImgV];
    [self addSubview:self.recommendTypeImV];
    [self addSubview:self.title];
    [self addSubview:self.iconImgV];
    [self addSubview:self.name];
    [self addSubview:self.recommendTime];
    [self addSubview:self.line];

    WS(weakSelf);
    [self.backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_top).offset(20);
        make.bottom.equalTo(weakSelf.mas_bottom).offset(-22);
        make.left.equalTo(weakSelf.mas_left).offset(15);
        make.width.mas_equalTo(@150);
    }];
    [self.recommendTypeImV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.backImgV.mas_top);
        make.left.equalTo(weakSelf.backImgV.mas_left);
        make.width.mas_equalTo(@24);
        make.height.mas_equalTo(@17);
    }];
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.backImgV.mas_top);
        make.left.equalTo(weakSelf.backImgV.mas_left).offset(167);
        make.right.equalTo(weakSelf.mas_right).offset(-13);
    }];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.title.mas_bottom).offset(11);
        make.left.equalTo(weakSelf.backImgV.mas_right).offset(16);
        make.width.mas_equalTo(@23);
        make.height.mas_equalTo(@23);
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.title.mas_bottom).offset(10);
        make.left.equalTo(weakSelf.iconImgV.mas_right).offset(8.5);
        make.right.equalTo(weakSelf.mas_right).offset(84);
        make.height.mas_equalTo(@24);
    }];
    [self.recommendTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.iconImgV.mas_bottom).offset(10.2);
        make.left.equalTo(weakSelf.iconImgV.mas_left);
        make.right.equalTo(weakSelf.mas_right);
        make.height.mas_equalTo(@17);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.mas_bottom).offset(-1);
        make.left.equalTo(weakSelf.mas_left).offset(15);
        make.right.equalTo(weakSelf.mas_right).offset(-15);
        make.height.mas_equalTo(@1);
    }];
 
}

#pragma mark -- LAZY LOADING
- (UIImageView *)backImgV{
    if (!_backImgV) {
        _backImgV = [[UIImageView alloc] init];
        _backImgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _backImgV;
}

- (UIImageView *)recommendTypeImV{
    if (!_recommendTypeImV) {
        _recommendTypeImV = [[UIImageView alloc]init];
    }
    return _recommendTypeImV;
}

- (UILabel *)title{
    if (!_title) {
        _title = [[UILabel alloc]init];
        _title.font = [UIFont systemFontOfSize:16];
        _title.numberOfLines = 2;
        
    }
    return _title;
}

- (UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        _iconImgV.clipsToBounds = YES;
        _iconImgV.layer.cornerRadius = 23/2;
        _iconImgV.backgroundColor = [UIColor  greenColor];
    }
    return _iconImgV;
}

- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc]init];
        _name.font = [UIFont systemFontOfSize:12];
        _name.textColor = COLOR(45, 45, 52, 1);
        [_name sizeToFit];
    }
    return _name;
}

- (UILabel *)recommendTime{
    if (!_recommendTime) {
        _recommendTime = [[UILabel alloc]init];
        _recommendTime.textColor = COLOR(153, 153, 153, 1);
        _recommendTime.font = [UIFont systemFontOfSize:12];
        [_recommendTime sizeToFit];
    }
    return _recommendTime;
}

- (UILabel *)line{
    if (!_line) {
        _line = [[UILabel alloc]init];
        _line.backgroundColor = COLOR(235, 236, 237, 1);
    }
    return _line;
}
@end
