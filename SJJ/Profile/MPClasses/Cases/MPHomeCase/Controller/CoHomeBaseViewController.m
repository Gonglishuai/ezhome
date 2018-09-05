//
//  CoHomeBaseViewController.m
//  Consumer
//
//  Created by 樊诗媛 on 16/8/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoHomeBaseViewController.h"
#import "MPHomeViewController.h"
#import "SHSegmentedControl.h"
#import "SHMemberModel.h"
#import "MPSearchCaseViewController.h"
#import "MPHome3DViewController.h"
#import "SHRNViewController.h"
#import <ESFoundation/UMengServices.h>

@interface CoHomeBaseViewController ()<SHSegmentedControlDelegate, UIViewControllerTransitioningDelegate>
@property (nonatomic, strong)   UIButton *searchButton;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) MPHomeViewController * home_2D_vc;
@property (nonatomic, strong) MPHome3DViewController * home_3D_vc;

@end

@implementation CoHomeBaseViewController
{
    UIButton *  _personalInfoBtn;
    SHMemberModel *_model;
    UIButton *filterButton;
    UIButton *seachButton;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self checkMemberType];
//    [self updatePersonalInfoBtn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBaseUI];
//    [self setupNavigationBar];
}
- (void) setupNavigationBar
{
    [super setupNavigationBar];
    self.menuLabel.hidden = YES;
    self.leftButton.hidden = !_isFromHome;
}

- (void)loadBaseUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.rightButton.hidden = YES;
    
    seachButton = [UIButton buttonWithType:UIButtonTypeCustom];
    seachButton.frame = CGRectMake(SCREEN_WIDTH - 47, NAVBAR_HEIGHT-44, 44, 44);
    [seachButton addTarget:self action:@selector(tapOnRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [seachButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal] ;
    [self.navgationImageview addSubview:seachButton];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 0084ff
    SHSegmentedControl *segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-90, NAVBAR_HEIGHT-44, 190, 44)];
    segment.lineColor = [UIColor stec_blueTextColor];
    segment.titleColor = [UIColor stec_blueTextColor];
    segment.titlePlaceColor = [UIColor stec_titleTextColor];
    segment.delegate = self;
    [segment createSegUIWithTitles:@[@"效果图",@"3D方案"]];
    [self.navgationImageview addSubview:segment];
       
    
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBAR_HEIGHT - TABBAR_HEIGHT)];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    [self addSubControllers];
    
    [self createFilterButton];
    
    [self.view bringSubviewToFront:self.navgationImageview];
}
- (void)filterButtonClick {

    if (_currentVC == _home_2D_vc) {
        [UMengServices eventWithEventId:Event_case_2D_filter];
        
        [_home_2D_vc filter2DCases];
        filterButton.tag = 10;
    }
    else if (_currentVC == _home_3D_vc) {
        [UMengServices eventWithEventId:Event_case_3D_filter];
        
        [_home_3D_vc filter3DCases];
        filterButton.tag = 20;
    }
 }
- (void)tapOnRightButton:(id)sender
{
    MPSearchCaseViewController *search = [[MPSearchCaseViewController alloc] init];
    
    if (_currentVC == _home_2D_vc) {
        [UMengServices eventWithEventId:Event_case_2D_search];
        search.searchType = @"2D";
    }
    else if (_currentVC == _home_3D_vc) {
        
        [UMengServices eventWithEventId:Event_case_3D_search];
        search.searchType = @"3D";
    }
    
    [self customPushViewController:search animated:YES];
    
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - privatemethods
- (void)createFilterButton {
    filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.frame = CGRectMake(SCREEN_WIDTH-85, NAVBAR_HEIGHT-44,44,44);
    [filterButton setImage:[UIImage imageNamed:@"nav_screen"] forState:UIControlStateNormal];
    [filterButton addTarget:self action:@selector(filterButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navgationImageview addSubview:filterButton];
}

- (void)addSubControllers{
    _home_2D_vc = [[MPHomeViewController alloc]init];
    _home_2D_vc.isFromHome = _isFromHome;
    [self addChildViewController:_home_2D_vc];
    
    _home_3D_vc = [[MPHome3DViewController alloc]init];
    _home_3D_vc.isFromHome = _isFromHome;
    [self addChildViewController:_home_3D_vc];
    
    [self fitFrameForChildViewController:_home_2D_vc];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:_home_2D_vc.view];
    
    _currentVC = _home_2D_vc;
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if ((index == 0 && _currentVC == _home_2D_vc) || (index == 1 && _currentVC == _home_3D_vc)) {
        return;
    }
    switch (index) {
        case 0:
        {
            [UMengServices eventWithEventId:Event_case_2D];
            [self fitFrameForChildViewController:_home_2D_vc];
            [self transitionFromOldViewController:_currentVC toNewViewController:_home_2D_vc];
            break;
        }
        case 1:
        {
            [UMengServices eventWithEventId:Event_case_3D];
            [self fitFrameForChildViewController:_home_3D_vc];
            [self transitionFromOldViewController:_currentVC toNewViewController:_home_3D_vc];
            break;
        }
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

#pragma mark - 检测用户是否设置用户类型
- (void)checkMemberType
{
    // 未登录状态不处理
    if (![ESLoginManager sharedManager].isLogin) return;
    
    // 用户类型存在不处理
    if ([JRKeychain loadSingleUserInfo:UserInfoCodeType].length > 0) return;
    
    // 未设置用户类型, 去设置
//    SHRNViewController *setMemberTypeController = [[SHRNViewController alloc] init];
//    [self presentViewController:setMemberTypeController animated:NO completion:nil];
    
    [MGJRouter openURL:@"/UserCenter/LogIn"];
}

@end
