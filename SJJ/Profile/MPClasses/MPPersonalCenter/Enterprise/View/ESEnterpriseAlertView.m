
#import "ESEnterpriseAlertView.h"

@interface ESEnterpriseAlertView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *failureSubTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertButton;

@property (nonatomic, copy) void (^callback)(ESEnterpriseAlertType type);

@end

@implementation ESEnterpriseAlertView
{
    UIView *_blackBackgroundView;
    UIView *_backgroundView;
    
    ESEnterpriseAlertType _type;
}

+ (instancetype)createEnterpriseAlertView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ESEnterpriseAlertView"
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
    
    self.alertButton.layer.masksToBounds = YES;
    self.alertButton.layer.cornerRadius = CGRectGetHeight(self.alertButton.frame)/2.0f;
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 6.0f;
}

+ (void)showAlertWithType:(ESEnterpriseAlertType)type
                 callback:(void (^) (ESEnterpriseAlertType type))callback
{
    if (type == ESEnterpriseAlertTypeUnknow)
    {
        return;
    }
    
    ESEnterpriseAlertView *view = [ESEnterpriseAlertView createEnterpriseAlertView];
    CGFloat alertX = SCREEN_WIDTH <= 320 ? 50.0f : 70.0f;
    CGFloat alertWidth = SCREEN_WIDTH - alertX * 2;
    CGFloat alertHeight = alertWidth * (572/484.0f);
    CGFloat alertY = (SCREEN_HEIGHT - alertHeight)/2.0f - 30.0f;
    view.frame = CGRectMake(alertX, alertY, alertWidth, alertHeight);
    [view showAlertWithType:type
                   callback:callback];
}

- (void)showAlertWithType:(ESEnterpriseAlertType)type
                 callback:(void (^) (ESEnterpriseAlertType type))callback
{
    self.callback = callback;
    _type = type;
    
    [self updateViewWithType];
    
    [_backgroundView addSubview:_blackBackgroundView];
    [_backgroundView addSubview:self];
    
    _blackBackgroundView.alpha = 0.5f;
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundView];
    
    [self animationShowAlert];
}

- (void)updateViewWithType
{
    NSString *iconName = nil;
    NSString *title = nil;
    NSString *subTitle = nil;
    NSString *failureSubTitle = nil;
    NSString *buttonTitle = nil;
    BOOL showFailureSubTitle = NO;
    if (_type == ESEnterpriseAlertTypeSuccess)
    {
        showFailureSubTitle = NO;
        iconName = @"create_success";
        title = @"创建成功";
        subTitle = @"您的施工项目创建成功~";
        failureSubTitle = @"";
        buttonTitle = @"知道了";
    }
    else if (_type == ESEnterpriseAlertTypeFailure)
    {
        showFailureSubTitle = YES;
        iconName = @"create_failure";
        title = @"创建失败";
        subTitle = @"您的施工项目创建失败！";
        failureSubTitle = @"请确认信息后重新提交";
        buttonTitle = @"重试";
    }
    else
    {
        return;
    }
    
    self.imageView.image = [UIImage imageNamed:iconName];
    self.titleLabel.text = title;
    self.subTitleLabel.text = subTitle;
    self.failureSubTitleLabel.hidden = !showFailureSubTitle;
    self.failureSubTitleLabel.text = failureSubTitle;
    [self.alertButton setTitle:buttonTitle
                      forState:UIControlStateNormal];
}

#pragma mark - Button Method
- (IBAction)alertButtonDidTapped:(id)sender
{
    SHLog(@"知道了");
    
    [self animationHideAlert];
    
    if (self.callback)
    {
        self.callback(_type);
    }
}

#pragma mark - animation
- (void)animationShowAlert
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3f;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
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
