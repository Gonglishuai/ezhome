//
//  ESAlertView.m
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESAlertView.h"
#import "UIColor+Stec.h"
#import "UIFont+Stec.h"

@interface ESAlertView()

@property(nonatomic,weak) UIButton *bgButton;

@property(nonatomic,weak) UIView *contentView;
@property(nonatomic,weak) UILabel *titleLabel, *tipsLable;
@property(nonatomic,weak) UIButton *button;
@property(nonatomic,weak) UIButton *doneBtn;

@property(nonatomic,strong) NSString *title, *message, *buttonTitle;
@property(nonatomic,assign) BOOL coverCanClicked;

@property(nonatomic,assign) NSInteger lineSpacing;
@property (strong, nonatomic) void(^btnClickedBlock)(void);
@end

@implementation ESAlertView

+ (ESAlertView *)sharedAlert
{
    static ESAlertView *sharedAlert;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAlert = [[ESAlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    sharedAlert.lineSpacing = 6;
    return sharedAlert;
}

#pragma mark - Show methods

+ (void)showTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle {
    ESAlertView *alert = [self sharedAlert];
    
    [alert showWithTitle:title tips:message btnTitle:buttonTitle btnClickBlock:nil coverCanClick:YES];
    [alert show];
}

+ (void)showTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle withClickedBlock:(void(^)(void))btnClickedBlock {
    ESAlertView *alert = [self sharedAlert];
    alert.btnClickedBlock = btnClickedBlock;
    [alert showWithTitle:title tips:message btnTitle:buttonTitle btnClickBlock:btnClickedBlock coverCanClick:NO];
    [alert show];
}

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

#pragma mark - Getter

- (UIButton *)bgButton {
    if (!_bgButton) {
        UIButton *bgButton = [[UIButton alloc] init];
        bgButton.backgroundColor = [UIColor blackColor];
        [bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bgButton];
        _bgButton = bgButton;
    }
    return _bgButton;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.backgroundColor = [UIColor whiteColor];
        contentView.layer.cornerRadius = 13;
        contentView.layer.masksToBounds = YES;
        
        contentView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
        [self.bgButton addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UILabel *)tipsLable {
    if (!_tipsLable) {
        UILabel *tipsLable = [[UILabel alloc] initWithFrame:CGRectZero];
        tipsLable.backgroundColor = [UIColor clearColor];
        tipsLable.adjustsFontSizeToFitWidth = YES;
        tipsLable.textAlignment = NSTextAlignmentLeft;
        tipsLable.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        tipsLable.numberOfLines = 0;
        tipsLable.minimumScaleFactor = 1;
        
        tipsLable.textColor = [UIColor stec_subTitleTextColor];
        tipsLable.font = [UIFont stec_subTitleFount];
        [self.contentView addSubview:tipsLable];
        _tipsLable = tipsLable;
    }
    return _tipsLable;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        titleLabel.textColor = [UIColor stec_titleTextColor];
        titleLabel.font = [UIFont stec_bigerTitleFount];
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        UIButton *doneBtn = [[UIButton alloc] init];
        doneBtn.titleLabel.font = [UIFont stec_titleFount];
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        doneBtn.backgroundColor = [UIColor stec_ableButtonBackColor];
        doneBtn.clipsToBounds = YES;
        [self.contentView addSubview:doneBtn];
        [doneBtn addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn = doneBtn;
    }
    return _doneBtn;
}

#pragma mark - Instance methods

- (void)showWithTitle:(NSString *)title
                 tips:(NSString *)tips
             btnTitle:(NSString *)btnTitle
        btnClickBlock:(void(^)(void))btnClickedBlock
        coverCanClick:(BOOL)isCoverCanClick {
    self.titleLabel.text = title;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tips];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:_lineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attributedString length])];
    self.tipsLable.attributedText = attributedString;
    
    [self.doneBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    if (btnClickedBlock) {
        self.btnClickedBlock = btnClickedBlock;
        [self.doneBtn addTarget:self action:@selector(btnClickedBlock) forControlEvents:UIControlEventTouchUpInside];
    }
    if(isCoverCanClick) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
    }
    [self setupFrame];
}


- (void)setupFrame {
    
    CGFloat marginToScreenLeft = 30;
    
    CGFloat marginToContentViewLeft = 20;
    CGFloat marginToContentViewTop = 20;
    
    CGFloat contentViewWidth = [UIScreen mainScreen].bounds.size.width - 2*marginToScreenLeft;
    
    CGFloat padding = 20;
    CGFloat subViewWidth = contentViewWidth-2*marginToContentViewLeft;
    
    //bgBtn
    self.bgButton.frame = self.bounds;
    
    //titleLabel
    self.titleLabel.frame = CGRectMake(marginToContentViewLeft, marginToContentViewTop, subViewWidth, 20);
    
    //tipsLabel
    NSString *tipsString = self.tipsLable.text;
    CGFloat tipsStringHeight;
    if (tipsString) {
        CGSize constraintSize = CGSizeMake(subViewWidth, [UIScreen mainScreen].bounds.size.height*0.6);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:_lineSpacing];
        CGRect tipsStringRect = [tipsString boundingRectWithSize:constraintSize
                                                         options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)
                                                      attributes:@{NSFontAttributeName: self.tipsLable.font, NSParagraphStyleAttributeName:paragraphStyle}
                                                         context:NULL];
        tipsStringHeight = tipsStringRect.size.height;
    } else {
        tipsStringHeight = 40;
    }
    
    self.tipsLable.frame = CGRectMake(marginToContentViewLeft, CGRectGetMaxY(self.titleLabel.frame) + padding, subViewWidth, tipsStringHeight);
    
    //doneBtn
    CGFloat doneBtnW = subViewWidth-20;
    CGFloat doneBtnH = 50;
    CGFloat doneBtnX = (contentViewWidth-doneBtnW)/2;
    self.doneBtn.frame = CGRectMake(doneBtnX, CGRectGetMaxY(self.tipsLable.frame)+30, doneBtnW, doneBtnH);
    self.doneBtn.layer.cornerRadius = doneBtnH/2;
    //contentView
    CGFloat contentViewHeight = CGRectGetMaxY(self.doneBtn.frame)+30;
    CGFloat contentViewX = (self.frame.size.width-contentViewWidth)/2;
    CGFloat contentViewY = (self.frame.size.height-contentViewHeight)/2;
    self.contentView.frame = CGRectMake(contentViewX, contentViewY, contentViewWidth, contentViewHeight);
}

#pragma mark - Show & Dismiss

- (void)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    [window.layer removeAllAnimations];
    [window addSubview:self];
    [self showBackground];
    [self showAlertAnimation];
}

- (void)lightColor {
    self.bgButton.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
    self.contentView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.1];
    self.doneBtn.alpha = 0.1;
    self.tipsLable.alpha = 0.1;
    self.titleLabel.alpha = 0.1;
}

- (void)darkColor {
    self.bgButton.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.doneBtn.alpha = 1.0;
    self.tipsLable.alpha = 1.0;
    self.titleLabel.alpha = 1.0;
}

- (void)showBackground {
    [self lightColor];
    [UIView animateWithDuration:0.25 animations:^{
        [self darkColor];
    }];
    NSLog(@"self=%@",self);
}

-(void)showAlertAnimation {
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.25;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [self.contentView.layer addAnimation:animation forKey:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:.025 animations:^{
        [self lightColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Button Actions

- (void)bgButtonClicked {
    [self dismiss];
}

- (void)doneBtnClicked {
    if (self.btnClickedBlock) {
        self.btnClickedBlock();
    }
    [self dismiss];
}


@end

