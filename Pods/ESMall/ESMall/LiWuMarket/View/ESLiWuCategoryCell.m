//
//  ESLiWuCategoryCell.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuCategoryCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface ESLiWuCategoryCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ESLiWuCategoryCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)updateCell:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getCategory:)]) {
        ESLiWuCategoryModel *model = [self.delegate getCategory:index];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.categoryImgurl] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        self.titleLabel.text = model.categoryName;
    }
}

- (void)setUpView {
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont stec_remarkTextFount]];
    [self.titleLabel setTextColor:[UIColor stec_subTitleTextColor]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];
    
    [self setUpConstraints];
}

- (void)setUpConstraints {
    __block UIView *b_contentView = self.contentView;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(b_contentView.mas_centerX);
        make.top.equalTo(b_contentView.mas_top);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(b_contentView.mas_centerX);
//        make.leading.equalTo(b_contentView.mas_leading);
//        make.trailing.equalTo(b_contentView.mas_trailing);
        make.width.greaterThanOrEqualTo(@(50));
        make.bottom.equalTo(b_contentView.mas_bottom);
        make.height.equalTo(@17);
    }];
}
@end
