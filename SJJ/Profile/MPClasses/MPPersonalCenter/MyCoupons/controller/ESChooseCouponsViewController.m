//
//  ESChooseCouponsViewController.m
//  Mall
//
//  Created by jiang on 2017/9/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESChooseCouponsViewController.h"
#import "SHSegmentedControl.h"
#import "ESCouponListViewController.h"

@interface ESChooseCouponsViewController ()<SHSegmentedControlDelegate>
@property (nonatomic, strong)SHSegmentedControl *segment;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) ESCouponListViewController *unUseListController;//可用
@property (nonatomic, strong) ESCouponListViewController *unableListController;//不可用

@property (strong, nonatomic) void(^myblock)(NSMutableDictionary*);
@property (strong, nonatomic) NSMutableDictionary *selectCouponInfo;

@property (copy, nonatomic) NSString *subOrderId;
@property (copy, nonatomic) NSString *orderId;
@end

@implementation ESChooseCouponsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"选择优惠券";
    self.rightButton.hidden = YES;
    
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    _segment.lineColor = [UIColor stec_blueTextColor];
    _segment.titleColor = [UIColor stec_blueTextColor];
    _segment.titlePlaceColor = [UIColor stec_titleTextColor];
    _segment.titleFont = 15.0f;
    _segment.delegate = self;
    [_segment createSegUIWithTitles:@[@"可用",@"不可用"]];
    [self.view addSubview:_segment];
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT))];
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_contentView];
    [self addSubControllers];
}

- (void)tapOnLeftButton:(id)sender {
    if (self.myblock) {
        self.myblock(_selectCouponInfo);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSubOrderId:(NSString *)subOrderId orderId:(NSString *)orderId CouponInfo:(NSMutableDictionary*)couponInfo block:(void(^)(NSMutableDictionary *couponDic))block {
    _selectCouponInfo = [NSMutableDictionary dictionary];
    _orderId = orderId;
    _subOrderId =subOrderId;
    _selectCouponInfo = [NSMutableDictionary dictionaryWithDictionary:couponInfo];
    _myblock = block;
}

- (void)addSubControllers{
    WS(weakSelf)
    _unUseListController = [[ESCouponListViewController alloc]init];
    [_unUseListController setStatus:CouponStatusAbleUse isCanSelect:YES subOrderId:_subOrderId orderId:_orderId];
    [_unUseListController setBlock:^(NSMutableDictionary *couponDic) {
        _selectCouponInfo = [NSMutableDictionary dictionaryWithDictionary:couponDic];
        if (couponDic.allKeys.count>0) {
            [weakSelf tapOnLeftButton:nil];
        } else {
        }
        
    }];
    [self addChildViewController:_unUseListController];
    
    _unableListController = [[ESCouponListViewController alloc]init];
    [_unableListController setStatus:CouponStatusUnableUse isCanSelect:NO subOrderId:_subOrderId orderId:_orderId];
    [self addChildViewController:_unableListController];
    
    [self fitFrameForChildViewController:_unUseListController];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:_unUseListController.view];
    
    _currentVC = _unUseListController;
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if ((index == 0 && _currentVC == _unUseListController) || (index == 1 && _currentVC == _unableListController)) {
        return;
    }
    switch (index) {
        case 0:
            [self fitFrameForChildViewController:_unUseListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_unUseListController];
            break;
        case 1:
            [self fitFrameForChildViewController:_unableListController];
            [self transitionFromOldViewController:_currentVC toNewViewController:_unableListController];
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

