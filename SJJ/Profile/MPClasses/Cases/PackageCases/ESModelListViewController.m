
#import "ESModelListViewController.h"
#import "ESModelListView.h"
#import "ESModelFilterViewController.h"
#import "ESSampleRoomListModel.h"
#import "MBProgressHUD.h"
#import "ESSampleRoomTagModel.h"
#import "ESCaseDetailViewController.h"
#import "ESCaseDetailViewController.h"
#import "CoCaseDetailController.h"
#import "ESModelSearchViewController.h"

@interface ESModelListViewController ()<ESModelListViewDelegate, ESModelFilterViewControllerDelegate>

@end

@implementation ESModelListViewController
{
    ESModelListView *_modelListView;
    UIView *_blackBackgroundView;
    UIView *_filterView;
    ESModelFilterViewController *_filterViewController;
    
    NSMutableArray *_arrayDS;
    NSArray *_arrTags;
    NSInteger _limit;
    NSInteger _offset;
    NSString *_tagStr;
    BOOL _isLoadMore;
    BOOL _showCountLabelStatus;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initUI];
    
    [self requestData];
    
    [self requestFilterTags];
}

- (void)initData
{
    _arrayDS = [NSMutableArray array];
    
    _limit = 10;
    _offset = 0;
    _tagStr = @"";
    
    _showCountLabelStatus = YES;
}

- (void)initUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    self.titleLabel.text = @"套餐样板间";
    [self.rightButton setImage:nil
                      forState:UIControlStateNormal];
    [self.rightButton setTitle:@"筛选"
                      forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor stec_titleTextColor]
                           forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont stec_titleFount];
    self.rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    
    _modelListView = [[ESModelListView alloc] initWithFrame:CGRectMake(
                                                                       0,
                                                                       NAVBAR_HEIGHT,
                                                                       SCREEN_WIDTH,
                                                                       SCREEN_HEIGHT - NAVBAR_HEIGHT
                                                                       )];
    _modelListView.viewDelegate = self;
    _modelListView.searchStatus = YES;
    [self.view addSubview:_modelListView];
}

- (void)requestData
{
    __weak ESModelListViewController *weakSelf = self;
    [MBProgressHUD showHUDAddedTo:_modelListView animated:YES];
    [ESSampleRoomListModel requestForSampleRoomListWithOffset:_offset
                                                        limlt:_limit
                                                       tagStr:_tagStr
                                                   searchTerm:nil success:^(ESSampleRoomListModel *model)
    {
        [weakSelf updateDataAndRefreshUIWithModel:model];
        [MBProgressHUD hideHUDForView:_modelListView animated:YES];
        
    } failure:^(NSError *error) {
        
        SHLog(@"样板间列表数据请求失败:%@", error.localizedDescription);
        
        [weakSelf updateRequestFailureUI];
        [MBProgressHUD hideHUDForView:_modelListView animated:YES];
    }];
}

- (void)updateDataAndRefreshUIWithModel:(ESSampleRoomListModel *)model
{
    if (!_isLoadMore)
    {
        [_arrayDS removeAllObjects];
        [_modelListView endHeaderRefreshStatus];
    }
    else
    {
        if (model.data
            && [model.data isKindOfClass:[NSArray class]]
            && model.data.count > 0)
        {
            [_modelListView endFooterRefreshWithNoMoreDataStatus:NO];
        }
        else
        {
            [_modelListView endFooterRefreshWithNoMoreDataStatus:YES];
        }
    }
    
    if (model.data
        && [model.data isKindOfClass:[NSArray class]])
    {
        [_arrayDS addObjectsFromArray:model.data];
    }
    
    if (_arrayDS.count <= 0)
    {
        [self showNoDataIn:_modelListView
                   imgName:@"nodata_datas"
                     frame:self.view.frame
                     Title:@"啊哦~暂时没有数据~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        
        [_modelListView tableViewReload];
        
        if (_showCountLabelStatus)
        {
            _showCountLabelStatus = NO;
            [_modelListView tableviewScrollToTop];
            [_modelListView showCountToast:model.count];
        }
    }
}

- (void)updateRequestFailureUI
{
    if (!_isLoadMore)
    {
        [_modelListView endHeaderRefreshStatus];
    }
    else
    {
        [_modelListView endFooterRefreshWithNoMoreDataStatus:NO];
    }
    
    [self showNoDataIn:_modelListView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [_modelListView beginRefreshing];
     }];
}

- (void)requestFilterTags
{
    [ESSampleRoomTagModel requestForSampleRoomFilterTagsSuccess:^(NSArray<ESSampleRoomTagModel *> *array)
    {
        
        _arrTags = array;
        
    } failure:^(NSError *error) {

        SHLog(@"获取样板间筛选数据失败:%@", error.localizedDescription);
    }];
}

#pragma mark - ESModelListViewDelegate
- (NSInteger)getModelCount
{
    if (_arrayDS
        && _arrayDS.count > 0)
    {
        return _arrayDS.count + 1;
    }
    
    return 0;
}

- (void)cellDidTappedWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        ESModelSearchViewController *vc = [[ESModelSearchViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        SHLog(@"搜索");
        return;
    }
    else if (indexPath.row - 1 >= _arrayDS.count)
    {
        return;
    }
    
    SHLog(@"第%ld个样板间被点击", (long)indexPath.row);
    ESSampleRoomModel *model = _arrayDS[indexPath.row - 1];
    if (model.caseEnumVersion == CaseVersionNew)
    {
        ESCaseDetailViewController *caseDetailVC = [[ESCaseDetailViewController alloc] init];
        if (model.caseEnumType == CaseType2D)
        {
            [caseDetailVC setCaseId:model.caseId caseStyle:CaseStyleType2D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
        }
        else if (model.caseEnumType == CaseType3D)
        {
            [caseDetailVC setCaseId:model.caseId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
        }
        else
        {
            SHLog(@"未知案例类型");
            return;
        }
        [self.navigationController pushViewController:caseDetailVC
                                             animated:YES];
    }
    else if (model.caseEnumVersion == CaseVersionOld)
    {
        UIViewController *caseDetailVC = nil;
        if (model.caseEnumType == CaseType2D)
        {
            caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:model.caseId];
        }
        else if (model.caseEnumType == CaseType3D)
        {
            ESCaseDetailViewController *vc = [[ESCaseDetailViewController alloc] init];
            [vc setCaseId:model.caseId caseStyle:CaseStyleType3D caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
            caseDetailVC = vc;
        }
        else
        {
            SHLog(@"未知案例类型");
            return;
        }
        [self.navigationController pushViewController:caseDetailVC
                                             animated:YES];
    }
    else
    {
        SHLog(@"未知案例版本");
    }
}

- (void)tableViewDidPull
{
    SHLog(@"下拉刷新");
    _isLoadMore = NO;
    _offset = 0;
    _showCountLabelStatus = YES;
    
    [self requestData];
}

- (void)tableViewDidPush
{
    SHLog(@"上拉加载更多");
    _isLoadMore = YES;
    _offset += 10;
    
    [self requestData];
}

#pragma mark - ESModelListCellDelegate
- (ESSampleRoomModel *)getModelListCellDataWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row - 1 < _arrayDS.count)
    {
        return _arrayDS[indexPath.row - 1];
    }
    
    return nil;
}

#pragma mark - ESModelSearchCellDelegate
- (NSString *)getSearchTipTextWithIndexPath:(NSIndexPath *)indexPath
{
    return @"输入套餐样板间关键词";
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapOnRightButton:(id)sender
{
    _blackBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    _blackBackgroundView.backgroundColor = [UIColor blackColor];
    _blackBackgroundView.alpha = 0.01;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(removeModelFilterView)];
    [_blackBackgroundView addGestureRecognizer:tap];
    [self.view addSubview:_blackBackgroundView];
    
    _filterViewController = [[ESModelFilterViewController alloc] init];
    _filterViewController.tags = _arrTags;
    _filterViewController.delegate = self;
    _filterView = _filterViewController.view;
    [self.view addSubview:_filterView];
    
    CGRect originalRect = CGRectMake(
                                     SCREEN_WIDTH * 0.2f,
                                     0,
                                     SCREEN_WIDTH * 0.8f,
                                     SCREEN_HEIGHT
                                     );
    _filterView.frame = CGRectMake(
                                   SCREEN_WIDTH,
                                   0,
                                   SCREEN_WIDTH,
                                   SCREEN_HEIGHT
                                   );
    [UIView animateWithDuration:0.3f animations:^{
        _filterView.frame = originalRect;
        _blackBackgroundView.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [_filterView layoutIfNeeded];
    }];
    
}

#pragma mark - ESModelFilterViewControllerDelegate
- (void)closeButtonDidTapped
{
    [self removeModelFilterView];
}

- (void)filterCompleteButtonDidTapped:(NSString *)tagsString
{
    SHLog(@"筛选的id:%@", tagsString);
    
    if (!tagsString
        || ![tagsString isKindOfClass:[NSString class]])
    {
        return;
    }
    
    [self removeModelFilterView];
    
    _tagStr = tagsString;
    
    [_modelListView beginRefreshing];
}

#pragma mark - Methods
- (void)removeModelFilterView
{
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         _filterView.frame = CGRectMake(
                                        SCREEN_WIDTH,
                                        0,
                                        SCREEN_WIDTH,
                                        SCREEN_HEIGHT
                                        );
         _blackBackgroundView.alpha = 0.01f;
     }
                     completion:^(BOOL finished)
     {
         [_filterView removeFromSuperview];
         
         _filterView = nil;
         _filterViewController.delegate = nil;
         _filterViewController = nil;
         
         [_blackBackgroundView removeFromSuperview];
         _blackBackgroundView = nil;
     }];
}

@end
