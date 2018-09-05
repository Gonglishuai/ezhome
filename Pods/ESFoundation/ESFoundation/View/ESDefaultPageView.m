//
//  ESDefaultPageView.m
//  Mall
//
//  Created by 焦旭 on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDefaultPageView.h"
#import "Masonry.h"
#import "DefaultSetting.h"
#import "ESDevice.h"
#import "UIColor+Stec.h"
#import "UIFont+Stec.h"

@interface ESDefaultPageView()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy)   void(^handler)(void);
@end

@implementation ESDefaultPageView

+ (void)showDefaultInView:(UIView *)view
                withImage:(NSString *)image
                 withText:(NSString *)text
          withButtonTitle:(NSString *)buttonTitle
              withHandler:(void (^)(void))handler {
    ESDefaultPageView *defaultView = [self defaultForView:view];
    if (defaultView == nil) {
        defaultView = [[ESDefaultPageView alloc] initWithView:view];
        defaultView.backgroundColor = [UIColor whiteColor];
    }
    
    [defaultView.imageView setImage:[UIImage imageNamed:image]];
    [defaultView.textLabel setAttributedText:[self getAttributedStr:text]];
    defaultView.textLabel.textAlignment = NSTextAlignmentCenter;
    [defaultView.button setTitle:buttonTitle forState:UIControlStateNormal];
    defaultView.handler = handler;
}

+ (void)hideDefaultFromView:(UIView *)view {
    ESDefaultPageView *defaultView = [self defaultForView:view];
    if (defaultView != nil) {
        [defaultView removeFromSuperview];
    }
}

+ (ESDefaultPageView *)defaultForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (ESDefaultPageView *)subview;
        }
    }
    return nil;
}

+ (NSMutableAttributedString *)getAttributedStr:(NSString *)string {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    return attributedString;
}

- (void)buttonClick:(UIButton *)sender {
    if (self.handler) {
        self.handler();
    }
}

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    if (self) {
        [view addSubview:self];
        
        __block UIView *b_view = view;
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(b_view.mas_top);
            make.leading.equalTo(b_view.mas_leading);
            make.bottom.equalTo(b_view.mas_bottom);
            make.trailing.equalTo(b_view.mas_trailing);
        }];
        
        [self setConstraints];
    }
    return self;
}

- (void)setConstraints {
    WS(weakSelf);
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.centerY.equalTo(weakSelf.mas_centerY).with.offset(- 53 * SCREEN_HEIGHT / 667.0);
        make.height.greaterThanOrEqualTo(@0);
        make.left.equalTo(weakSelf.mas_left).with.offset(15);
        make.right.equalTo(weakSelf.mas_right).with.offset(-15);
    }];
    
    __block UIView *b_backView = self.backView;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(121, 121));
        make.top.equalTo(b_backView.mas_top).with.offset(0);
        make.centerX.equalTo(b_backView.mas_centerX);
    }];
    
    __block UIImageView *b_imgView = self.imageView;
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_imgView.mas_bottom).with.offset(15);
        make.left.equalTo(b_backView.mas_left).with.offset(0);
        make.right.equalTo(b_backView.mas_right).with.offset(0);
        make.height.greaterThanOrEqualTo(@30);
    }];
    
    __block UILabel *b_textLabel = self.textLabel;
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(b_textLabel.mas_bottom).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(123, 42));
        make.bottom.equalTo(b_backView.mas_bottom).with.offset(-15);
        make.centerX.equalTo(b_backView.mas_centerX);
    }];
}

#pragma mark - Getter
- (UIView *)backView {
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        [self addSubview:_backView];
        
        [_backView addSubview:self.imageView];
        [_backView addSubview:self.textLabel];
        [_backView addSubview:self.button];
    }
    return _backView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeCenter];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor stec_subTitleTextColor];
        _textLabel.font = [UIFont stec_titleFount];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIButton *)button {
    if (_button == nil) {
        _button = [[UIButton alloc] init];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont fontWithName:@"" size:15.0f]];
        _button.backgroundColor = [UIColor stec_ableButtonBackColor];
        _button.clipsToBounds = YES;
        _button.layer.cornerRadius = 21.0f;
        [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
@end

