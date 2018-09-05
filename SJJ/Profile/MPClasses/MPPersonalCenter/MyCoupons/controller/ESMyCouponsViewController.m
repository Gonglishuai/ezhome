//
//  ESMyCouponsViewController.m
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyCouponsViewController.h"
#import "SHSegmentedControl.h"
#import "ESCouponListViewController.h"

@interface ESMyCouponsViewController ()<SHSegmentedControlDelegate>
@property (nonatomic, strong)SHSegmentedControl *segment;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) ESCouponListViewController *unUseListController;//未使用
@property (nonatomic, strong) ESCouponListViewController *usedListController;//已使用
@property (nonatomic, strong) ESCouponListViewController *overdueListController;//已过期
@end

@implementation ESMyCouponsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"我的优惠券";
    self.rightButton.hidden = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    _segment.lineColor = [UIColor stec_blueTextColor];
    _segment.titleColor = [UIColor stec_blueTextColor];
    _segment.titlePlaceColor = [UIColor stec_titleTextColor];
    _segment.titleFont = 15.0f;
    _segment.delegate = self;
    [_segment createSegUIWithTitles:@[@"未使用",@"已使用",@"已过期"]];
    [self.view addSubview:_segment];
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT))];
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_contentView];
    [self addSubControllers];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSubControllers{
    _unUseListController = [[ESCouponListViewController alloc]init];
    [_unUseListController setStatus:CouponStatusUnUse isCanSelect:NO subOrderId:@"" orderId:@""];
    [self addChildViewController:_unUseListController];
    
    _usedListController = [[ESCouponListViewController alloc]init];
    [_usedListController setStatus:CouponStatusUsed isCanSelect:NO subOrderId:@"" orderId:@""];
    [self addChildViewController:_usedListController];
    
    _overdueListController = [[ESCouponListViewController alloc]init];
    [_overdueListController setStatus:CouponStatusOverdue isCanSelect:NO subOrderId:@"" orderId:@""];
    [self addChildViewController:_overdueListController];

    
    [self fitFrameForChildViewController:_unUseListController];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:_unUseListController.view];
    
    _currentVC = _unUseListController;
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if ((index == 0 && _currentVC == _unUseListController) || (index == 1 && _currentVC == _usedListController)||(index == 2 && _currentVC == _overdueListController)) {
        return;
    }
    switch (index) {
        case 0:
            [self fitFrameForChildViewController:_unUseListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_unUseListController];
            break;
        case 1:
            [self fitFrameForChildViewController:_usedListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_usedListController];
            break;
        case 2:
            [self fitFrameForChildViewController:_overdueListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_overdueListController];
            break;
        default:
            break;
    }
}

#pragma mark - NavigationControllerDelegate
- (void)fitFrameForChildViewController:(UIViewController *)chileViewController{
    
    CGRect frame = self.contentView.frame;
    frame.origin.y = 0;
    chileViewController.view.frame = frame;
}

- (void)transitionFromOldViewController:(UIViewController *)oldViewController toNewViewController:(UIViewController *)newViewController{
    
    [self transitionFromViewController:oldViewController toViewController:newViewController duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newViewController didMoveToParentViewController:self];
            _currentVC = newViewController;
        }else{
            _currentVC = oldViewController;
        }
    }];
}

- (void)removeAllChildViewControllers{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
