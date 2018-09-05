//
//  ESMyGoldViewController.m
//  Mall
//
//  Created by jiang on 2017/9/7.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyGoldViewController.h"
#import "SHSegmentedControl.h"
#import "ESGoldListViewController.h"
#import "ESAlertView.h"

@interface ESMyGoldViewController ()<SHSegmentedControlDelegate>

@property (nonatomic, strong)SHSegmentedControl *segment;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) ESGoldListViewController *backListController;//返现
@property (nonatomic, strong) ESGoldListViewController *usedListController;//消费

@end

@implementation ESMyGoldViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"装修基金";
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.rightButton setTitle:@"使用说明" forState:UIControlStateNormal];
    
    _segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    _segment.lineColor = [UIColor stec_blueTextColor];
    _segment.titleColor = [UIColor stec_blueTextColor];
    _segment.titlePlaceColor = [UIColor stec_titleTextColor];
    _segment.titleFont = 15.0f;
    _segment.delegate = self;
    [_segment createSegUIWithTitles:@[@"返现金额",@"消费记录"]];
    [self.view addSubview:_segment];
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT))];
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_contentView];
    [self addSubControllers];
    
}

- (void)addSubControllers{
    _backListController = [[ESGoldListViewController alloc]init];
    [_backListController setType:@"1"];
    [self addChildViewController:_backListController];
    
    _usedListController = [[ESGoldListViewController alloc]init];
    [_usedListController setType:@"2"];
    [self addChildViewController:_usedListController];

    [self fitFrameForChildViewController:_backListController];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:_backListController.view];
    
    _currentVC = _backListController;
}
- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapOnRightButton:(id)sender {
    [ESAlertView showTitle:@"使用说明" message:@"1、装修基金最低使用额度为1元，且需为1元的整数倍。\n2、有效期为2017-9-23 0:00:00至2017-10-31 23:59:59。\n3、相关订单取消后，有效期内的装修基金将在24小时内返回至您的账户中，逾期不退。\n4、因活动期间订单较多，在您支付成功后，装修基金将在60分钟内返还至您的账户中。" buttonTitle:@"知道了" withClickedBlock:^{
        SHLog(@"点击回调");
    }];
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if ((index == 0 && _currentVC == _backListController) || (index == 1 && _currentVC == _usedListController)) {
        return;
    }
    switch (index) {
        case 0:
            [self fitFrameForChildViewController:_backListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_backListController];
            break;
        case 1:
            [self fitFrameForChildViewController:_usedListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_usedListController];
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
