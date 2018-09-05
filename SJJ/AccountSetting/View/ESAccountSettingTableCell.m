//
//  ESAccountSettingTableCell.m
//  Homestyler
//
//  Created by shiyawei on 28/6/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESAccountSettingTableCell.h"

#import "Masonry.h"

@interface ESAccountSettingTableCell ()
@property (nonatomic,strong)    UIImageView *selectImgView;
@end


@implementation ESAccountSettingTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        
        [self createUIView];
    }
    return self;
}
#pragma mark --- set设置
- (void)setCellType:(ESAccountSettingTableCellType)cellType {
    _cellType = cellType;
    switch (cellType) {
        case ESAccountSettingTableCellTypeSlected:
            [self createSelectImgView];
            break;
        case ESAccountSettingTableCellTypeAccessory:
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case ESAccountSettingTableCellTypeNone:
            self.accessoryType = UITableViewCellAccessoryNone;
        break;
        default:
            break;
    }
}
- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        self.selectImgView.image = [UIImage imageNamed:@"pay_select"];
    }else {
        self.selectImgView.image = [UIImage imageNamed:@""];
    }
}
#pragma mark --- private method
- (void)createUIView {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15);
        make.top.mas_offset(0);
        make.bottom.mas_offset(0);
    }];
    
    [self addSubview:self.subLabel];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(0);
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.bottom.mas_offset(0);
    }];
    
    [self addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-35);
        make.top.mas_offset(0);
        make.bottom.mas_offset(0);
    }];
}
- (void)createSelectImgView {
    [self addSubview:self.selectImgView];
    UIImage *image = [UIImage imageNamed:@"pay_unSelect"];
    CGFloat h = image.size.height;
    CGFloat w = image.size.width;
    [self.selectImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.mas_offset(w);
        make.height.mas_offset(h);
    }];
}
#pragma mark --- 懒加载
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont stec_buttonFount];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _titleLabel;
}
- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = [UIFont stec_priceFount];
        _subLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    return _subLabel;
}
- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont stec_titleFount];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _detailLabel;
}
- (UIImageView *)selectImgView {
    if (!_selectImgView) {
        _selectImgView = [[UIImageView alloc] init];

    }
    return _selectImgView;
}
@end
