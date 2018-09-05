//
//  ESQRCodeView.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESQRCodeView.h"
#import "JRKeychain.h"
#import "SHAlertView.h"
#import "SHQRCodeGenerate.h"
#import "CoSpringAnimation.h"
#import "ESQRCodeMainView.h"

@interface ESQRCodeView()<ESQRCodeMainViewDelegate>

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) ESQRCodeMainView *alertView;

@end

@implementation ESQRCodeView

+ (instancetype)qrCodeView {
    static ESQRCodeView *s_request = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        s_request = [[super allocWithZone:NULL]init];
    });
    
    return s_request;
}

///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [ESQRCodeView qrCodeView];
}

///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [ESQRCodeView qrCodeView];
}

#pragma mark - Lazy Loading
- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0.0f;
    }
    return _maskView;
}

- (ESQRCodeMainView *)alertView {
    if (_alertView == nil) {
        NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"ESQRCodeMainView" owner:nil options:nil];
        _alertView = [nibView objectAtIndex:0];
        CGFloat width = 242;
        CGFloat height = 376;
        CGFloat x = (SCREEN_WIDTH - width)/2;
        CGFloat y = SCREEN_SCALE * 190;
        _alertView.frame = CGRectMake(x, y, width, height);
        _alertView.alpha = 0.0f;
        _alertView.delegate = self;
        _alertView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        _alertView.layer.cornerRadius = 10;
//        _alertView.layer.shadowColor = [UIColor blackColor].CGColor;
//        _alertView.layer.shadowOffset = CGSizeMake(0, 5);
//        _alertView.layer.shadowOpacity = 0.3f;
//        _alertView.layer.shadowRadius = 10.0f;
    }
    return _alertView;
}

- (void)initQRCodeWithView:(UIWindow *)window {
    NSDictionary *userInfo = [JRKeychain loadAllUserInfo];
    
    NSString *mobile_number = [userInfo objectForKey:kUserInfoCodePhone] ? [userInfo objectForKey:kUserInfoCodePhone] : @"";
    NSString *name = [userInfo objectForKey:kUserInfoCodeName] ? [userInfo objectForKey:kUserInfoCodeName] : @"";
    NSString *member_id = [userInfo objectForKey:kUserInfoCodeJId] ? [userInfo objectForKey:kUserInfoCodeJId] : @"";
    NSString *avatar = [userInfo objectForKey:kUserInfoCodeAvatar] ? [userInfo objectForKey:kUserInfoCodeAvatar] : @"";
    NSString *member_type = [userInfo objectForKey:kUserInfoCodeType] ? [userInfo objectForKey:kUserInfoCodeType] : @"";
//    NSString *hs_uid = [userInfo objectForKey:kUserInfoCodeHsUid] ? [userInfo objectForKey:kUserInfoCodeHsUid] : @"";
    
    
    NSDictionary *inforDict = @{@"mobile_number":mobile_number,
                                @"name":name,
                                @"member_id":member_id,
                                @"avatar":avatar,
                                @"member_type":member_type
                                
                                };//@"hs_uid":hs_uid
    
    if (name == 0) {
        [SHAlertView showAlertWithMessage:@"资料为空" sureKey:nil];
        return;
    }
    
    SHLog(@"member information:%@",inforDict);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:inforDict options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *informationString= [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [SHQRCodeGenerate createQRCodeWithString:informationString complete:^(UIImage *QRImage) {
        
        [[ESQRCodeView qrCodeView].alertView setQRImage:QRImage];
        [[ESQRCodeView qrCodeView] showInView:window];
    }];
}

+ (void)showInView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:[ESQRCodeView qrCodeView].maskView];
    [window addSubview:[ESQRCodeView qrCodeView].alertView];
    [[ESQRCodeView qrCodeView] initQRCodeWithView:window];
}

+ (void)hiddenInView:(UIViewController *)vc {
    [[ESQRCodeView qrCodeView] hiddenInView:vc.view];
}

- (void)showInView:(UIView *)view {
    // Fade in the grey overlay
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0.5f;
    } completion:NULL];
    
    // Fade in the alert view
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.alpha = 1.0f;
    } completion:NULL];
    
    // Scale-animate in the alert view
    CoSpringAnimation *scale = [CoSpringAnimation animationWithKeyPath:@"transform.scale"];
    scale.damping = 30;
    scale.stiffness = 14;
    scale.mass = 1;
    scale.fromValue = @(1.4);
    scale.toValue = @(1.0);
    
    [self.alertView.layer addAnimation:scale forKey:scale.keyPath];
    self.alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

- (void)hiddenInView:(UIView *)view {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.maskView.alpha = 0.0f;
        self.alertView.alpha = 0.0f;
    } completion:NULL];
    
    // Scale-animate in the alert view
    CoSpringAnimation *scaleAnimation = [CoSpringAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.damping = 11;
    scaleAnimation.stiffness = 11;
    scaleAnimation.mass = 1;
    scaleAnimation.fromValue = @(1.0);
    scaleAnimation.toValue = @(0.7);
    
    [self.alertView.layer addAnimation:scaleAnimation forKey:scaleAnimation.keyPath];
    self.alertView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [self.alertView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2f];
    [self.maskView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2f];
    self.alertView = nil;
    self.maskView = nil;
}

#pragma mark - CoFormDelegate
- (void)closeBtnClick {
    
    [self hiddenInView:self.maskView.superview];
}

@end
