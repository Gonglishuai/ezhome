//
//  ESLiWuProductCell.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuProductCell.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"

@interface ESLiWuProductCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *priceLabel;

@end

@implementation ESLiWuProductCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpSubViews];
        [self setUpSubViewsConstraints];
    }
    return self;
}

- (void)updateCell:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(getProduct:)]) {
        ESCMSModel *model = [self.delegate getProduct:index];
        
        NSString *url = model && model.extend_dic ? model.extend_dic.image : @"";
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"equal_default"]];
        
        self.infoLabel.text = model && model.extend_dic ? model.extend_dic.name : @"";
        
        self.priceLabel.text = model && model.extend_dic ? [NSString stringWithFormat:@"¥%@", model.extend_dic.price] : @"暂无报价";
    }
}

- (void)setUpSubViews {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.borderWidth = 0.5f;
    self.imageView.layer.cornerRadius = 2.0f;
    self.imageView.layer.borderColor = ColorFromRGA(0xEBECED, 1).CGColor;
    [self.contentView addSubview:self.imageView];
    
    self.infoLabel = [[UILabel alloc] init];
    [self.infoLabel setFont:[UIFont stec_paramsFount]];
    self.infoLabel.textColor = [UIColor stec_titleTextColor];
    self.infoLabel.numberOfLines = 2;
    [self.contentView addSubview:self.infoLabel];
    
    self.priceLabel = [[UILabel alloc] init];
    [self.priceLabel setFont:[UIFont stec_subTitleFount]];
    self.priceLabel.textColor = [UIColor stec_deleteRowActionBackColor];
    [self.contentView addSubview:self.priceLabel];
}

- (void)setUpSubViewsConstraints {
    __block UIView *b_contentView = self.contentView;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_contentView.mas_top);
        make.leading.equalTo(b_contentView.mas_leading);
        make.trailing.equalTo(b_contentView.mas_trailing);
        make.height.equalTo(b_contentView.mas_width);
    }];
    
    __block UIImageView *b_imageView = self.imageView;
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_imageView.mas_bottom).with.offset(12);
        make.leading.equalTo(b_contentView.mas_leading);
        make.trailing.equalTo(b_contentView.mas_trailing);
        make.height.greaterThanOrEqualTo(@21);
        make.height.lessThanOrEqualTo(@42);
    }];
    
    __block UILabel *b_infoLabel = self.infoLabel;
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(b_infoLabel.mas_bottom).with.offset(5);
        make.leading.equalTo(b_contentView.mas_leading);
        make.trailing.equalTo(b_contentView.mas_trailing);
        make.bottom.equalTo(b_contentView.mas_bottom).with.offset(-8);
        make.height.equalTo(@18.5);
    }];
}
@end
