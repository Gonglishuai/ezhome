//
//  ESMemberInfoCell.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfoCell.h"
#import <Masonry.h>

@interface ESMemberInfoCell()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;          //标题
@property (nonatomic, strong) UITextField *contentField;        //内容
@property (nonatomic, strong) UIImageView *contentImgView;  //内容右图标
@property (nonatomic, strong) UIView *bottomLine;           //底线

@property (nonatomic, strong) NSString *key;
@end

@implementation ESMemberInfoCell
- (void)updateCell:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getInfoModel:)]) {
        ESMemberInfoViewModel *model = [self.delegate getInfoModel:index];
        self.titleLabel.text = model.title;
        self.contentField.text = model.content;
        self.contentField.enabled = model.input;
        self.contentImgView.hidden = !model.edit;
        self.key = model.key;
        NSString *contentImg = model.input ? @"" : @"arrow_right";
        [self.contentImgView setImage:[UIImage imageNamed:contentImg]];
        self.contentField.keyboardType = model.keyboardType;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setUpSubViews];
        [self setUpSubViewsConstraints];
    }
    return self;
}

- (void)setUpSubViews {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor blackColor];
    [self.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    
    self.contentField = [[UITextField alloc] init];
    self.contentField.textColor = ColorFromRGA(0x999999, 1);
    self.contentField.textAlignment = NSTextAlignmentRight;
    self.contentField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contentField setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:15.0f]];
    [self.contentField setBorderStyle:UITextBorderStyleNone];
    self.contentField.delegate = self;
    [self.contentView addSubview:self.contentField];
    
    self.contentImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.contentImgView];
    
    self.bottomLine = [[UIView alloc] init];
    self.bottomLine.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self.contentView addSubview:self.bottomLine];
}

- (void)setUpSubViewsConstraints {
    __block UIView *b_contentView = self.contentView;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@47);
        make.width.greaterThanOrEqualTo(@50);
        make.width.lessThanOrEqualTo(@90);
        make.left.equalTo(b_contentView.mas_left).with.offset(15);
        make.top.equalTo(b_contentView.mas_top).with.offset(0);
    }];
    
    __block UILabel *b_titleLabel = self.titleLabel;
    [self.contentImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(8, 16));
        make.right.equalTo(b_contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(b_titleLabel.mas_centerY);
    }];
    
    __block UIImageView *b_contentImgView = self.contentImgView;
    [self.contentField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@47);
        make.left.equalTo(b_titleLabel.mas_right).with.offset(8);
        make.right.equalTo(b_contentImgView.mas_left).with.offset(-8);
        make.centerY.equalTo(b_titleLabel.mas_centerY);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@1);
        make.top.equalTo(b_titleLabel.mas_bottom).with.offset(0);
        make.left.equalTo(b_contentView.mas_left).with.offset(16);
        make.right.equalTo(b_contentView.mas_right).with.offset(-16);
        make.bottom.equalTo(b_contentView.mas_bottom).with.offset(0);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldEditComplete:withKey:)]) {
        [self.delegate textFieldEditComplete:textField withKey:self.key];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldEditBegin:withKey:)]) {
        [self.delegate textFieldEditBegin:textField withKey:self.key];
    }
}
@end
