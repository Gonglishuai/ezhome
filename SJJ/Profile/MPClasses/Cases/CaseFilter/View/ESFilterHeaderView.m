//
//  ESDesignFilterHeaderView.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterHeaderView.h"
#import <Masonry.h>

@interface ESFilterHeaderView()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ESFilterHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
        [self setUpConstraints];
    }
    return self;
}

- (void)updateHeader:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(getSectionHeader:)]) {
        NSString *title = [self.delegate getSectionHeader:section];
        self.titleLabel.text = title;
    }
}

- (void)setUpSubViews {
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    self.titleLabel.font = [UIFont stec_buttonFount];
    [self.contentView addSubview:self.titleLabel];
}

- (void)setUpConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).with.offset(16);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(40));
        make.width.greaterThanOrEqualTo(@(50));
    }];
}
@end
