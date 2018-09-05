//
//  ESCaseProduvtListViewController.m
//  Consumer
//
//  Created by jiang on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseProduvtListViewController.h"
#import "ESCaseRecommentListViewController.h"
#import "SHSegmentedControl.h"
#import "ESCaseAPI.h"
#import "MBProgressHUD+NJ.h"
#import "ESCaseCategoryModel.h"
#import <ESNetworking/SHRequestTool.h>

@interface ESCaseProduvtListViewController ()<SHSegmentedControlDelegate>
@property (nonatomic, strong) ESCaseRecommentListViewController *currentVC;
@property (nonatomic, strong) UIView *contentView;
@property (strong, nonatomic) NSMutableArray *datasSource;
@property (copy, nonatomic) NSString *caseId;
@end

@implementation ESCaseProduvtListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor stec_viewBackgroundColor];
    _datasSource = [NSMutableArray array];
    _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, DECORATION_SEGMENT_HEIGHT+NAVBAR_HEIGHT+1, SCREEN_WIDTH, SCREEN_HEIGHT - (DECORATION_SEGMENT_HEIGHT+NAVBAR_HEIGHT))];
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_contentView];
    
    [self requestData];
    
}

- (void) setupNavigationBar
{
    [super setupNavigationBar];
    self.titleLabel.text = @"推荐商品";
    self.rightButton.hidden = YES;
    self.leftButton.hidden = NO;
    
}
- (void)setCaseId:(NSString *)caseId {
    _caseId = caseId;
}

-(void)requestData{
    WS(weakSelf)
    [ESCaseAPI getCaseCategoryListWithSuccess:^(NSArray *array) {
        [weakSelf.datasSource removeAllObjects];
        [weakSelf.datasSource addObjectsFromArray:array];
        if (weakSelf.datasSource.count > 0) {
            [weakSelf removeNoDataView];
            [weakSelf loadBaseUI];
        } else {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_datas" frame:weakSelf.contentView.frame Title:@"啊哦~暂时没有数据~" buttonTitle:nil Block:nil];
        }
        
        
    } andFailure:^(NSError *error) {
        if (weakSelf.datasSource.count == 0) {
            [weakSelf showNoDataIn:weakSelf.view imgName:@"nodata_net" frame:weakSelf.contentView.frame Title:@"网络有问题\n刷新一下试试吧" buttonTitle:@"刷新" Block:^{
                [weakSelf requestData];
            }];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", [SHRequestTool getErrorMessage:error]] toView:weakSelf.view];
        }
    }];    
}

- (void)loadBaseUI{
    
    SHSegmentedControl *segment = [[SHSegmentedControl alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT+1 , SCREEN_WIDTH, DECORATION_SEGMENT_HEIGHT)];
    //    segment.selectedIndex = 2;
    segment.lineColor = [UIColor stec_blueTextColor];
    segment.titleColor = [UIColor stec_blueTextColor];
    segment.titlePlaceColor = [UIColor stec_titleTextColor];
    segment.titleFont = 15.0f;
    segment.delegate = self;
    NSMutableArray *titles = [NSMutableArray array];
    for (ESCaseCategoryModel *model in _datasSource) {
        [titles addObject:model.categoryName];
    }
    [segment createSegUIWithTitles:titles];
    [self.view addSubview:segment];
    
    
    
    [self addSubControllers];
    [self.view bringSubviewToFront:segment];
}

#pragma mark - privatemethods
- (void)addSubControllers{
    if (_datasSource.count > 0) {
        for (int i = 0; i < _datasSource.count; i++) {
            ESCaseRecommentListViewController *caseRecommentListViewCon = [[ESCaseRecommentListViewController alloc]init];
            caseRecommentListViewCon.tag = 100+i;
            ESCaseCategoryModel *model = _datasSource[i];
            [caseRecommentListViewCon setCaseId:_caseId categoryId:model.categoryId];
            [self addChildViewController:caseRecommentListViewCon];
            if (0 == i) {
                [self fitFrameForChildViewController:caseRecommentListViewCon];
                //设置默认显示在容器View的内容
                [self.contentView addSubview:caseRecommentListViewCon.view];
                
                _currentVC = caseRecommentListViewCon;
            }
        }
        
    }

    
    
}

- (void)tapOnLeftButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SHSegmentedControlDelegate
- (void)segBtnClickWithTitleIndex:(NSInteger)index
{
    if (index+100 == _currentVC.tag) {
        return;
    }
    ESCaseRecommentListViewController *caseRecommentListViewCon = [self.childViewControllers objectAtIndex:index];
    [self fitFrameForChildViewController:caseRecommentListViewCon];
    [self transitionFromOldViewController:_currentVC toNewViewController:caseRecommentListViewCon];
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
            _currentVC = (ESCaseRecommentListViewController*)newViewController;
        }else{
            _currentVC = (ESCaseRecommentListViewController *)oldViewController;
        }
    }];
}

- (void)removeAllChildViewControllers{
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
