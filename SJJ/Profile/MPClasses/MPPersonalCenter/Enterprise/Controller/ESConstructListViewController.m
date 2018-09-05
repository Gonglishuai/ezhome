
#import "ESConstructListViewController.h"
#import "ESConstructListView.h"
#import "MBProgressHUD.h"
#import "ESConstructListModel.h"
#import "ESConstructDetailViewController.h"

@interface ESConstructListViewController ()<ESConstructListViewDelegate>

@end

@implementation ESConstructListViewController
{
    NSMutableArray *_arrayDS;
    NSInteger _limit;
    NSInteger _offset;
    BOOL _isLoadMore;
    
    ESConstructListView *_constructListView;
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
    _arrayDS = [NSMutableArray array];
    _limit = 10;
    _offset = 0;
    _isLoadMore = NO;
}

- (void)initUI
{
    self.rightButton.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.titleLabel.text = @"我的项目";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect rect = CGRectMake(
                             0,
                             NAVBAR_HEIGHT,
                             SCREEN_WIDTH,
                             SCREEN_HEIGHT - NAVBAR_HEIGHT
                             );
    _constructListView = [[ESConstructListView alloc] initWithFrame:rect];
    _constructListView.viewDelegate = self;
    [self.view addSubview:_constructListView];
}

- (void)requestData
{
    __weak ESConstructListViewController *weakSelf = self;
    __weak UIView *weakView = _constructListView;
    [MBProgressHUD showHUDAddedTo:_constructListView animated:YES];
    [ESConstructListModel requestConstructListWithOffset:_offset
                                                   limlt:_limit
                                                 success:^(ESConstructListModel *model)
    { 
        [weakSelf updateDataAndRefreshUIWithModel:model];
        [MBProgressHUD hideHUDForView:weakView animated:YES];
        
    } failure:^(NSError *error) {
        
        SHLog(@"施工订单列表:%@", error.localizedDescription);
        
        [weakSelf updateRequestFailureUI];
        [MBProgressHUD hideHUDForView:weakView animated:YES];
    }];
}

- (void)updateDataAndRefreshUIWithModel:(ESConstructListModel *)model
{
    if (!_isLoadMore)
    {
        [_arrayDS removeAllObjects];
        [_constructListView endHeaderRefreshStatus];
    }
    else
    {
        if (model.data
            && [model.data isKindOfClass:[NSArray class]]
            && model.data.count > 0)
        {
            [_constructListView endFooterRefreshWithNoMoreDataStatus:NO];
        }
        else
        {
            [_constructListView endFooterRefreshWithNoMoreDataStatus:YES];
        }
    }
    
    if (model.data
        && [model.data isKindOfClass:[NSArray class]])
    {
        [_arrayDS addObjectsFromArray:model.data];
    }
    
    if (_arrayDS.count <= 0)
    {
        [self showNoDataIn:_constructListView
                   imgName:@"nodata_datas"
                     frame:self.view.frame
                     Title:@"啊哦~暂时没有数据~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        
        [_constructListView constructTableViewReload];
    }
}

- (void)updateRequestFailureUI
{
    if (!_isLoadMore)
    {
        [_constructListView endHeaderRefreshStatus];
    }
    else
    {
        [_constructListView endFooterRefreshWithNoMoreDataStatus:NO];
    }
    
    __weak ESConstructListView *weakListView = _constructListView;
    [self showNoDataIn:_constructListView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [weakListView beginRefreshing];
     }];
}

#pragma mark - ESConstructListViewDelegate
- (NSInteger)getConstructListRowsWithSection:(NSInteger)section
{
    return _arrayDS.count;
}

- (void)tableViewDidPull
{
    SHLog(@"下拉刷新");
    _isLoadMore = NO;
    _offset = 0;
    
    [self requestData];
}

- (void)tableViewDidPush
{
    SHLog(@"上拉加载更多");
    _isLoadMore = YES;
    _offset += _limit;
    
    [self requestData];
}

#pragma mark - ESConstructListCellDelegate
- (ESConstructModel *)getConstructDataWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _arrayDS.count)
    {
        return _arrayDS[indexPath.row];
    }
    
    return nil;
}

- (void)constructDetailDidTapped:(NSIndexPath *)indexPath
{
    SHLog(@"第%ld个施工项目被点击", (long)indexPath.row);
    if (indexPath.row < _arrayDS.count)
    {
        ESConstructModel *model = _arrayDS[indexPath.row];
        ESConstructDetailViewController *vc = [[ESConstructDetailViewController alloc] initWithprojectId:model.projectNum];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
