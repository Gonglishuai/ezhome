
#import "ESGoldAlertView.h"

@interface ESGoldAlertView ()

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *sureButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cancelButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, copy) void (^callback)(BOOL sureStatus);

@end

@implementation ESGoldAlertView
{
    UIView *_blackBackgroundView;
    UIView *_backgroundView;
}

+ (instancetype)createGoldAlertView
{
    NSArray *array = [[ESMallAssets hostBundle] loadNibNamed:@"ESGoldAlertView"
                                                       owner:self
                                                     options:nil];
    return [array firstObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initUI];
}

- (void)initUI
{
    [self layoutIfNeeded];
    
    _blackBackgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _blackBackgroundView.alpha = 0.0f;
    _blackBackgroundView.backgroundColor = [UIColor blackColor];
    
    _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = CGRectGetHeight(self.sureButton.frame)/2.0f;
    self.cancelButton.layer.masksToBounds = YES;
    self.cancelButton.layer.cornerRadius = CGRectGetHeight(self.cancelButton.frame)/2.0f;
    self.cancelButton.layer.borderColor = [UIColor stec_subTitleTextColor].CGColor;
    self.cancelButton.layer.borderWidth = 0.5f;

    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6.0f;
    
    NSString *text = self.messageLabel.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8.0f];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [text length])];
    self.messageLabel.attributedText = attributedString;
}

+ (void)showGoldAlertViewCallBack:(void(^)(BOOL sureStatus))callback
{
    ESGoldAlertView *view = [ESGoldAlertView createGoldAlertView];
    CGFloat alertX = SCREEN_WIDTH <= 320 ? 40.0f : 60.0f;
    CGFloat alertWidth = SCREEN_WIDTH - alertX * 2;
    CGFloat alertHeight = alertWidth * (6/5.0f);
    CGFloat alertY = (SCREEN_HEIGHT - alertHeight)/2.0f - 30.0f;
    view.frame = CGRectMake(alertX, alertY, alertWidth, alertHeight);
    view.callback = callback;
    [view showGoldAlert];
}

- (void)showGoldAlert
{
    [_backgroundView addSubview:_blackBackgroundView];
    [_backgroundView addSubview:self];
    
    _blackBackgroundView.alpha = 0.5f;
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundView];
    
    [self animationShowAlert];
}

#pragma mark - Button Method
- (IBAction)sureButtonDidTapped:(id)sender
{
    [self animationHideAlert];
    if (self.callback)
    {
        self.callback(YES);
    }
}

- (IBAction)cancelButtonDidTapped:(id)sender
{
    [self animationHideAlert];
    if (self.callback)
    {
        self.callback(NO);
    }
}

#pragma mark - animation
- (void)animationShowAlert
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5f;
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addAnimation:animation forKey:nil];
    
    _blackBackgroundView.alpha = 0.1f;
    __weak UIView *weakView = _blackBackgroundView;
    [UIView animateWithDuration:0.3f animations:^{
        weakView.alpha = 0.5f;
    }];
}

- (void)animationHideAlert
{
    [self removeFromSuperview];
    
    __weak UIView *weakView = _blackBackgroundView;
    [UIView animateWithDuration:0.15 animations:^{
        weakView.alpha = 0.01f;
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
    }];
}

@end
