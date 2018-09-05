//
//  MPBaseViewController.m
//  MarketPlace
//
//  Created by xuezy on 15/12/16.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import "MPBaseViewController.h"
#import "SHUnreadBubbleView.h"
#import "NoDataView.h"
#import "DefaultSetting.h"
#import "UIColor+Stec.h"
#import "ESFoundationAssets.h"

static CGFloat titleTrailing = 98.0f;
@interface MPBaseViewController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>
{
    SHUnreadBubbleView*     _unreadBubble;
}

@property (nonatomic, weak)	UIView* scrollableView;
@property (assign, nonatomic) float lastContentOffset;
@property (strong, nonatomic) UIPanGestureRecognizer* panGesture;
@property (strong, nonatomic) UIView* overlay;
@property (assign, nonatomic) BOOL isCollapsed;
@property (assign, nonatomic) BOOL isExpanded;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supplementaryWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondarySupplementaryWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supplementaryButtonHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *secondarySupplementaryTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *supplementaryTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightButtonTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;

@property (strong, nonatomic) NoDataView *noDataView;

@end

@implementation MPBaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.delegate = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self initNavigationBar];
    
    NSLog(@"当前控制器名称:%@", NSStringFromClass([self class]));
}


/// According to the side view.
- (IBAction)tapOnLeftButton:(id)sender
{
    NSLog(@"tapOnLeftButton");
}


- (IBAction)tapOnRightButton:(id)sender
{
    NSLog(@"tapOnRightButton");
}


- (IBAction)tapOnSupplementaryButton:(id)sender
{
    NSLog(@"tapOnSupplementaryButton");
}

- (IBAction)tapOnSecondarySupplementaryButton:(id)sender
{
    NSLog(@"tapOnSecondarySupplementaryButton");
}

-(void)constraintNavbarView:(UIView*)view
{
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:NAVBAR_HEIGHT]];
}


- (void)initNavigationBar
{
    [[[ESFoundationAssets hostBundle] loadNibNamed:@"SHNavigationBarView" owner:self options:nil] firstObject];
    [self.view addSubview:self.navgationImageview];
    [self constraintNavbarView:self.navgationImageview];
    [self setupNavigationBar];
    [self updateNavigationBar];
//    _designerAvatar.clipsToBounds = YES;
//    _designerAvatar.layer.cornerRadius = 37/2;
}


- (void) setupNavigationBar
{

}


- (void) updateNavigationBar
{
    //need to check ways for better handling
    double minSpacingFromRight = 14.0;
    if (self.rightButton.hidden)
    {
        if (!self.supplementaryButton.hidden)
        {
            self.supplementaryTrailingConstraint.constant = minSpacingFromRight;
            
            if(!self.secondarySupplementaryButton.hidden)
            {
                self.secondarySupplementaryTrailingConstraint.constant = minSpacingFromRight;
                self.secondarySupplementaryTrailingConstraint.constant += self.supplementaryWidthConstraint.constant;
                self.secondarySupplementaryTrailingConstraint.constant += 2;
            }
        }
        else if(!self.secondarySupplementaryButton.hidden)
            self.secondarySupplementaryTrailingConstraint.constant = minSpacingFromRight;
        
    }
    else
    {
        CGFloat trailingMargin = self.rightButtonWidthConstraint.constant + minSpacingFromRight;
        
        if (self.supplementaryButton.hidden && !self.secondarySupplementaryButton.hidden)
            self.secondarySupplementaryTrailingConstraint.constant = trailingMargin + 2;
    }
    
    self.titleTrailingConstraint.constant = titleTrailing;
    if (self.secondarySupplementaryButton && !self.secondarySupplementaryButton.hidden && !self.supplementaryButton.hidden)
    {
        self.titleTrailingConstraint.constant += self.secondarySupplementaryWidthConstraint.constant;
        
        self.titleLeadingContraint.constant = self.titleTrailingConstraint.constant;
    }

    
    [self.view updateConstraintsIfNeeded];
}

-(void)setTitleCenterAligned
{
    _titleLabel.textColor = [UIColor stec_titleTextColor];
    
    [NSLayoutConstraint deactivateConstraints:self.titleLabel.constraints];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    //Width
    [_titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier:1
                                                       constant:200]];
    
    //Height
    [_titleLabel addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute: NSLayoutAttributeNotAnAttribute
                                                     multiplier:1
                                                       constant:_titleHeightConstraint.constant]];
    //centerX
    [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_mainContainer
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0]];
    //centerY
    [_mainContainer addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_mainContainer
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0]];
}



- (void) setRightButtonBadgeValue:(NSUInteger)count
{
    if (!_unreadBubble)
    {
        _unreadBubble =     [[[ESFoundationAssets hostBundle] loadNibNamed:@"SHUnreadBubbleView"
                                                           owner:nil
                                                         options:nil] firstObject];
        _unreadBubble.translatesAutoresizingMaskIntoConstraints = NO;

        [self.rightButton addSubview:_unreadBubble];

        [self.rightButton
         addConstraint:[NSLayoutConstraint constraintWithItem:_unreadBubble
                                                    attribute:NSLayoutAttributeTop
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.rightButton.imageView
                                                    attribute:NSLayoutAttributeTop
                                                   multiplier:1
                                                     constant:-7]];

        [self.rightButton
         addConstraint:[NSLayoutConstraint constraintWithItem:_unreadBubble
                                                    attribute:NSLayoutAttributeTrailing
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self.rightButton.imageView
                                                    attribute:NSLayoutAttributeTrailing
                                                   multiplier:1
                                                     constant:7]];
    }
    
    _unreadBubble.hidden = YES;

    if (count > 0)
    {
        _unreadBubble.hidden = NO;
        [_unreadBubble setCount:count];
    }
}


- (void)followScrollView:(UIView*)scrollableView
{
    self.scrollableView = scrollableView;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    
    [self.panGesture setDelegate:self];
    [self.scrollableView addGestureRecognizer:self.panGesture];
    
    /// The navbar fadeout is achieved using an overlay view with the same barTintColor.
    /// this might be improved by adjusting the alpha component of every navbar child.
    CGRect frame = self.navgationImageview.frame;
    frame.origin = CGPointZero;
    self.overlay = [[UIView alloc] initWithFrame:frame];
    if (!self.navgationImageview.backgroundColor) {
        NSLog(@"[%s]: %@", __func__, @"Warning: no bar tint color set");
    }
    [self.overlay setBackgroundColor:self.navgationImageview.backgroundColor];
    [self.overlay setUserInteractionEnabled:NO];
    [self.navgationImageview addSubview:self.overlay];
    [self.overlay setAlpha:0];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    
//    return YES;
//    
//}

- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    CGPoint translation = [gesture translationInView:[self.scrollableView superview]];
    
    float delta = self.lastContentOffset - translation.y;
    self.lastContentOffset = translation.y;
    
    CGRect frame;
    
    if (delta > 0) {
        if (self.isCollapsed) {
            return;
        }
        
        frame = self.navgationImageview.frame;
        
        if (frame.origin.y - delta < -NAVBAR_HEIGHT) {
            delta = frame.origin.y + NAVBAR_HEIGHT;
        }
        
        frame.origin.y = MAX(-NAVBAR_HEIGHT, frame.origin.y - delta);
        self.navgationImageview.frame = frame;
        
        if (frame.origin.y == -NAVBAR_HEIGHT) {
            self.isCollapsed = YES;
            self.isExpanded = NO;
        }
        
        [self updateSizingWithDelta:delta];
        
        /// Keeps the view's scroll position steady until the navbar is gone.
        if ([self.scrollableView isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView*)self.scrollableView setContentOffset:CGPointMake(((UIScrollView*)self.scrollableView).contentOffset.x, ((UIScrollView*)self.scrollableView).contentOffset.y - delta)];
        }
    }
    
    if (delta < 0) {
        
        if (self.isExpanded) {
            
            return;
        }
        
        frame = self.navgationImageview.frame;
        
        if (frame.origin.y - delta > 0) {
            delta = frame.origin.y ;
        }
        frame.origin.y = MIN(0, frame.origin.y - delta);
        self.navgationImageview.frame = frame;
        
        if (frame.origin.y == 0) {
            self.isExpanded = YES;
            self.isCollapsed = NO;
        }
        
        [self updateSizingWithDelta:delta];
    }
    
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        
        /// Reset the nav bar if the scroll is partial.
        self.lastContentOffset = 0;
        [self checkForPartialScroll];
    }
}

- (void)checkForPartialScroll {
    
    CGFloat pos = self.navgationImageview.frame.origin.y;
    
    
    if (pos >= -20) { // Get back down
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame;
            frame = self.navgationImageview.frame;
            CGFloat delta = frame.origin.y -0;
            frame.origin.y = MIN(0, frame.origin.y - delta);
            self.navgationImageview.frame = frame;
            
            self.isExpanded = YES;
            self.isCollapsed = NO;
            
            [self updateSizingWithDelta:delta];
            
            /// This line needs tweaking.
            // [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y - delta) animated:YES];
        }];
    } else {
        
        [UIView animateWithDuration:0.2 animations:^{ // And back up
            CGRect frame;
            frame = self.navgationImageview.frame;
            CGFloat delta = frame.origin.y + NAVBAR_HEIGHT;
            frame.origin.y = MAX(-NAVBAR_HEIGHT, frame.origin.y - delta);
            self.navgationImageview.frame = frame;
            
            self.isExpanded = NO;
            self.isCollapsed = YES;
            
            [self updateSizingWithDelta:delta];
        }];
    }
}

- (void)updateSizingWithDelta:(CGFloat)delta {
    
    CGRect frame = self.navgationImageview.frame;
    
    float alpha = (frame.origin.y + NAVBAR_HEIGHT) / frame.size.height;
    [self.overlay setAlpha:1 - alpha];
    self.navgationImageview.backgroundColor = [self.navgationImageview.backgroundColor colorWithAlphaComponent:alpha];
    
//    frame = self.scrollableView.superview.frame;
//    frame.origin.y = self.navgationImageview.frame.origin.y;
//    frame.size.height = frame.size.height + delta;
//    self.scrollableView.superview.frame = frame;
//    
//    /// Changing the layer's frame avoids UIWebView's glitchiness.
//    frame = self.scrollableView.layer.frame;
//    frame.size.height += delta;
//    self.scrollableView.layer.frame = frame;
}

- (void)endRefreshView:(BOOL)isLoadMore {
    if (!isLoadMore) {
        if (self.refreshForLoadNew)
            self.refreshForLoadNew();
    } else {
        if (self.refreshForLoadMore)
            self.refreshForLoadMore();
    }
}

- (void)customPushViewController:(UIViewController *)controller animated:(BOOL)animated {
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:animated];
}

- (NSString *)stringTypeChineseToEnglishWithString:(NSString *)string {
    NSString *plistPath = [[ESFoundationAssets hostBundle] pathForResource:@"MPSearchEnglish" ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSString *stringEnglish = [NSString stringWithFormat:@"%@",dictionary[string]];
    return stringEnglish;
    
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


/**
 展示空白页
 
 @param superView 添加空白页的view
 @param imgName 图片名
 @param frame 空白页frame
 @param title 描述
 @param buttonTitle button名字  无按钮传 nil 或 @""
 @param block button点击回调
 */
- (void)showNoDataIn:(UIView *)superView imgName:(NSString *)imgName frame:(CGRect)frame Title:(NSString *)title buttonTitle:(NSString *)buttonTitle Block:(void(^)())block; {
    if (_noDataView == nil) {
        _noDataView = [NoDataView creatWithImgName:imgName title:title buttonTitle:buttonTitle Block:block];
    } else {
        [_noDataView setWithImgName:imgName title:title buttonTitle:buttonTitle Block:block];
    }
    _noDataView.frame = frame;
    [superView addSubview:_noDataView];
    [superView bringSubviewToFront:_noDataView];
}

- (void)removeNoDataView {
    if (_noDataView != nil) {
        [_noDataView removeFromSuperview];
    }
}

- (void)showLocationAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"定位服务已关闭" message:@"您需要打开定位权限,才可以进入商城查看。请到设置->隐私->定位服务中开启【居然设计家】定位服务。" preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                       if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                                           [[UIApplication sharedApplication] openURL:url];
                                                           
                                                       }
                                                   }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - dealloc
- (void)dealloc
{
    NSLog(@"当前控制器被销毁:%@", NSStringFromClass([self class]));
}

@end
