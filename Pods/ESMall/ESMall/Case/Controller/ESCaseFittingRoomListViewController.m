
#import "ESCaseFittingRoomListViewController.h"
#import "ESCaseFittingRoomListView.h"
#import "ESCaseFittingRoomListNavigator.h"
#import "ESCaseFittingSampleRoomListModel.h"
#import "ESFittingSampleModel.h"
#import "MBProgressHUD.h"
//#import "ESCaseDetailViewController.h"

@interface ESCaseFittingRoomListViewController ()
<
ESCaseFittingRoomListViewDelegate,
ESCaseFittingRoomListNavigatorDelegate
>

@end

@implementation ESCaseFittingRoomListViewController
{
    ESCaseFittingRoomListView *_fittingRoomListView;
    ESCaseFittingRoomListNavigator *_navigatorBarView;
    NSInteger _limit;
    NSInteger _offset;
    NSMutableArray *_arrayDS;
    BOOL _needUpdateHeader;
    UIView *_errorBackgroundView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self requestData];
}

- (void)initData
{
    _offset = 0;
    _limit = 10;
    _arrayDS = [NSMutableArray array];
    
    _needUpdateHeader = YES;
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navgationImageview removeFromSuperview];
    
    CGRect listViewFrame = self.view.bounds;
    _fittingRoomListView = [[ESCaseFittingRoomListView alloc] initWithFrame:listViewFrame];
    _fittingRoomListView.viewDelegate = self;
    [self.view addSubview:_fittingRoomListView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, STATUSBAR_HEIGHT, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"master_leftArrow"]
             forState:UIControlStateNormal];
    UIEdgeInsets insets = backBtn.imageEdgeInsets;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(
                                                 insets.top,
                                                 insets.left + 8.0f,
                                                 insets.bottom,
                                                 insets.right
                                                 )];
    [backBtn addTarget:self
                action:@selector(tapOnLeftButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    _navigatorBarView = [ESCaseFittingRoomListNavigator caseFittingRoomListNavigator];
    _navigatorBarView.frame = CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    _navigatorBarView.delegate = self;
    _navigatorBarView.alpha = 0.0f;
    if ([self.sampModel.spaceTitle isKindOfClass:[NSString class]])
    {
        _navigatorBarView.navigatorTitleLabel.text = [self.sampModel.spaceTitle stringByAppendingString:@"试衣间"];
    }
    [self.view addSubview:_navigatorBarView];
    
    _errorBackgroundView = [[UIView alloc] initWithFrame:
                            CGRectMake(0,
                                       NAVBAR_HEIGHT,
                                       SCREEN_WIDTH,
                                       SCREEN_HEIGHT - NAVBAR_HEIGHT)];
    [self.view insertSubview:_errorBackgroundView atIndex:0];
}

- (void)requestData
{
    __weak ESCaseFittingRoomListViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:_fittingRoomListView animated:YES];
    [ESCaseFittingSampleRoomListModel
     requestForFittingRoomListWithOffset:_offset
     limlt:_limit
     apaceType:self.sampModel.spaceType
     success:^(ESCaseFittingSampleRoomListModel *model)
    {
        [weakSelf updateDataAndRefreshUIWithModel:model];
        [MBProgressHUD hideHUDForView:_fittingRoomListView animated:YES];
        
    } failure:^(NSError *error) {
        
        SHLog(@"试衣间列表数据请求失败:%@", error.localizedDescription);
        
        [weakSelf updateRequestFailureUI];
        [MBProgressHUD hideHUDForView:_fittingRoomListView animated:YES];
    }];
}

- (void)updateDataAndRefreshUIWithModel:(ESCaseFittingSampleRoomListModel *)model
{
    if (model.data
        && [model.data isKindOfClass:[NSArray class]]
        && model.data.count > 0)
    {
        [_fittingRoomListView endFooterRefreshWithNoDataStatus:NO];
    }
    else
    {
        [_fittingRoomListView endFooterRefreshWithNoDataStatus:YES];
    }
    
    if (model.data
        && [model.data isKindOfClass:[NSArray class]])
    {
        [_arrayDS addObjectsFromArray:model.data];
    }
    
    if (_arrayDS.count <= 0)
    {
        [self.view bringSubviewToFront:_errorBackgroundView];
        _navigatorBarView.alpha = 1.0f;
        
        [self showNoDataIn:_errorBackgroundView
                   imgName:@"nodata_datas"
                     frame:self.view.frame
                     Title:@"啊哦~暂时没有数据~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        _navigatorBarView.alpha = 0.0f;

        [_fittingRoomListView tableViewReload];
    }
    
    if (_needUpdateHeader)
    {
        _needUpdateHeader = NO;
        [_fittingRoomListView updateHeaderView];
    }
}

- (void)updateRequestFailureUI
{
    [_fittingRoomListView endFooterRefreshWithNoDataStatus:NO];
    _navigatorBarView.alpha = 1.0f;
    [self.view bringSubviewToFront:_errorBackgroundView];

    __weak ESCaseFittingRoomListViewController *weakSelf = self;
    [self showNoDataIn:_errorBackgroundView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         _navigatorBarView.alpha = 0.0f;
         [weakSelf.view sendSubviewToBack:_errorBackgroundView];
         [weakSelf requestData];
     }];
}

#pragma mark - ESCaseFittingRoomListViewDelegate
- (NSInteger)getFittingRoomListRowsAtSection:(NSInteger)section
{
    return _arrayDS.count;
}

- (void)fittingRoomListDidPush
{
    SHLog(@"上拉加载更多");
    
    _offset += _limit;
    [self requestData];
}

- (void)tableViewDidScrollWithY:(CGFloat)y
{
    SHLog(@"%lf", y);
    if (y <= 0 && -y <= NAVBAR_HEIGHT * 2)
    {
        _navigatorBarView.alpha = (NAVBAR_HEIGHT * 2 + y)/(NAVBAR_HEIGHT * 1.0f);
    }
    else
    {
        if (y > 0)
        {
            if (_navigatorBarView.alpha != 1.0f)
            {
                _navigatorBarView.alpha = 1.0f;
            }
        }
        else
        {
            if (_navigatorBarView.alpha != 0.0f)
            {
                _navigatorBarView.alpha = 0.0f;
            }
        }
    }
}

- (ESFittingSampleModel *)getHeaderData
{
    return self.sampModel;
}

- (void)fittingCaseDidTappedWithIndex:(NSInteger)index
{
    SHLog(@"第 %ld 个案例被点击", index);
    if (index < _arrayDS.count)
    {
        ESFittingSampleRoomModel *sampleModel = _arrayDS[index];
        NSString *brandId = sampleModel.brandId?sampleModel.brandId:@"";
        NSString *caseId = sampleModel.caseId?sampleModel.caseId:@"";
        NSString *caseType = sampleModel.caseEnumType == CaseType2D ? @"2d" : @"3d";
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:brandId forKey:@"brandId"];
        [info setObject:caseId forKey:@"caseId"];
        [info setObject:caseType forKey:@"caseType"];
        [MGJRouter openURL:@"/Case/CaseDetail/FittingRoom" withUserInfo:info completion:nil];
    }
}

#pragma mark - ESCaseFittingRoomListCellDelegate
- (ESFittingSampleRoomModel *)getFittingRoomListCellDataWithIndex:(NSIndexPath *)indexPath
{
    if (indexPath.row < _arrayDS.count)
    {
        return _arrayDS[indexPath.row];
    }
    
    return nil;
}

#pragma mark - ESCaseFittingRoomListNavigatorDelegate
- (void)backButtonDidTapped
{
    [self tapOnLeftButton:nil];
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
