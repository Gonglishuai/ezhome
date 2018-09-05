//
//  ESRecommendViewController.m
//  Consumer
//
//  Created by jiang on 2018/2/26.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import "ESRecommendViewController.h"
#import "SHSegmentedControl.h"

#import "ESRecommendListViewController.h"
#import "ESBrandRecommendListViewController.h"
#import "ESRecommendSearchViewController.h"
#import "ESBrandRecommendSearchViewController.h"
#import "EZHome-Swift.h"



@interface ESRecommendViewController ()<SHSegmentedControlDelegate>
@property (nonatomic, strong)SHSegmentedControl *segment;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) ESRecommendListViewController *recommendListViewCon;//推荐清单
@property (nonatomic, strong) ESBrandRecommendListViewController *brandRecommendListViewCon;//品牌清单

@end

@implementation ESRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"推荐清单";
    self.rightButton.hidden = YES;
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    _segment.lineColor = [UIColor stec_blueTextColor];
    _segment.titleColor = [UIColor stec_blueTextColor];
    _segment.titlePlaceColor = [UIColor stec_titleTextColor];
    _segment.titleFont = 15.0f;
    _segment.delegate = self;
    [_segment createSegUIWithTitles:@[@"推荐商品",@"推荐品牌"]];
    [self.view addSubview:_segment];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBrandRecommend) name:Brand_Recommend_Change object:nil];
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-(NAVBAR_HEIGHT+DECORATION_SEGMENT_HEIGHT))];
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_contentView];
    [self addSubControllers];
    [self createScreenButton];
}

- (void)createScreenButton {
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    searchButton.frame = CGRectMake(SCREEN_WIDTH - 87, NAVBAR_HEIGHT-44, 44, 44);
    [searchButton addTarget:self action:@selector(searchDesignerClick) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setImage:[UIImage imageNamed:@"nav_search"] forState:UIControlStateNormal] ;
    [self.navgationImageview addSubview:searchButton];
    
    UIButton *screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    screenButton.frame = CGRectMake(SCREEN_WIDTH-47, NAVBAR_HEIGHT-44,44,44);
    [screenButton setImage:[UIImage imageNamed:@"nav_create"] forState:UIControlStateNormal];
    [screenButton addTarget:self action:@selector(screenClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navgationImageview addSubview:screenButton];
    
    
}

- (void)screenClick {
    SHLog(@"添加");
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *createBrand = [UIAlertAction actionWithTitle:@"创建品牌清单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ESCreateBrandListViewController *createBrandListViewCon = [[ESCreateBrandListViewController alloc] initWithBrandId:@""];
        [self.navigationController pushViewController:createBrandListViewCon animated:YES];
    }];
    [alerVC addAction:createBrand];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alerVC addAction:cancel];
    
    [self presentViewController:alerVC animated:YES completion:nil];
}

- (void)searchDesignerClick {
    if (_currentVC == _recommendListViewCon) {
        ESRecommendSearchViewController *recommendSearchViewCon = [[ESRecommendSearchViewController alloc] init];
        [self.navigationController pushViewController:recommendSearchViewCon animated:YES];
    } else {
        ESBrandRecommendSearchViewController *brandRecommendSearchViewCon = [[ESBrandRecommendSearchViewController alloc] init];
        [self.navigationController pushViewController:brandRecommendSearchViewCon animated:YES];
    }
}

- (void)refreshBrandRecommend {
    [_brandRecommendListViewCon refresh];
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)addSubControllers{
    _recommendListViewCon = [[ESRecommendListViewController alloc]init];
    [self addChildViewController:_recommendListViewCon];
    
    _brandRecommendListViewCon = [[ESBrandRecommendListViewController alloc]init];
    [self addChildViewController:_brandRecommendListViewCon];
    
    [self fitFrameForChildViewController:_recommendListViewCon];
    //设置默认显示在容器View的内容
    [self.contentView addSubview:_recommendListViewCon.view];
    
    _currentVC = _recommendListViewCon;
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if ((index == 0 && _currentVC == _recommendListViewCon) || (index == 1 && _currentVC == _brandRecommendListViewCon)) {
        return;
    }
    switch (index) {
            case 0:
            [self fitFrameForChildViewController:_recommendListViewCon];
            [self transitionFromOldViewController:_currentVC toNewViewController:_recommendListViewCon];
            break;
            case 1:
            [self fitFrameForChildViewController:_brandRecommendListViewCon];
            [self transitionFromOldViewController:_currentVC toNewViewController:_brandRecommendListViewCon];
            break;
        default:
            break;
    }
}

#pragma mark - NavigationControllerDelegate
- (void)fitFrameForChildViewController:(UIViewController *)chileViewController {
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

