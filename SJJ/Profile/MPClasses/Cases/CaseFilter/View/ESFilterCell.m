//
//  ESFilterCell.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterCell.h"
#import <Masonry.h>

@interface ESFilterCell()
@property (nonatomic, strong) UILabel *tagLabel;
@end

@implementation ESFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 5;
        self.contentView.layer.borderWidth = 1;
        [self setUpSubViews];
        [self setUpConstraints];
    }
    return self;
}

- (void)updateCell:(NSInteger)section andIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getFilterItemText:andIndex:)]) {
        NSString *title = [self.delegate getFilterItemText:section andIndex:index];
        self.tagLabel.text = title;
    }
    if ([self.delegate respondsToSelector:@selector(filterItemIsSelected:andIndex:)]) {
        BOOL selected = [self.delegate filterItemIsSelected:section andIndex:index];
        self.tagLabel.textColor = selected ? [UIColor stec_blueTextColor] : [UIColor stec_titleTextColor];
        self.contentView.layer.borderColor = selected ? [UIColor stec_blueTextColor].CGColor : [UIColor stec_lineGrayColor].CGColor;
    }
}

- (void)setUpSubViews {
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.font = [UIFont stec_titleFount];
    self.tagLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.tagLabel];
}

- (void)setUpConstraints {
    [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).with.offset(5);
        make.trailing.equalTo(self.contentView.mas_trailing).with.offset(-5);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(40));
    }];
}
@end
