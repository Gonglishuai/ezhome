
#import "ESTransactionDetailViewController.h"
#import "ESTransactionListModel.h"
#import "ESTransactionDetailView.h"
#import "MBProgressHUD.h"

@interface ESTransactionDetailViewController ()<ESTransactionDetailViewDelegate>

@end

@implementation ESTransactionDetailViewController
{
    NSMutableArray *_arrayDS;
    NSInteger _limit;
    NSInteger _offset;
    BOOL _isLoadMore;
    NSString *_orderNum;
    
    ESTransactionDetailView *_transactionDetailView;
}

- (instancetype)initWithOrderNumber:(__kindof NSString *)orderNum
{
    self = [super init];
    if (self)
    {
        _orderNum = orderNum;
    }
    return self;
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.rightButton.hidden = YES;
    self.titleLabel.text = @"交易明细";

    CGRect rect = CGRectMake(
                             0,
                             NAVBAR_HEIGHT,
                             SCREEN_WIDTH,
                             SCREEN_HEIGHT - NAVBAR_HEIGHT
                             );
    _transactionDetailView = [[ESTransactionDetailView alloc] initWithFrame:rect];
    _transactionDetailView.viewDelegate = self;
    [self.view addSubview:_transactionDetailView];
}

- (void)requestData
{
    __weak ESTransactionDetailViewController *weakSelf = self;
    __weak UIView *weakView = _transactionDetailView;
    [MBProgressHUD showHUDAddedTo:_transactionDetailView animated:YES];
    [ESTransactionListModel requestTransactionistWithOffset:_offset
                                                      limlt:_limit
                                                   orderNum:_orderNum
                                                    success:^(ESTransactionListModel *model)
     {
         [weakSelf updateDataAndRefreshUIWithModel:model];
         [MBProgressHUD hideHUDForView:weakView animated:YES];
         
     } failure:^(NSError *error) {
         
         SHLog(@"交易明细列表:%@", error.localizedDescription);
         
         [weakSelf updateRequestFailureUI];
         [MBProgressHUD hideHUDForView:weakView animated:YES];
     }];
}

- (void)updateDataAndRefreshUIWithModel:(ESTransactionListModel *)model
{
    if (!_isLoadMore)
    {
        [_arrayDS removeAllObjects];
        [_transactionDetailView endHeaderRefreshStatus];
    }
    else
    {
        if (model.data
            && [model.data isKindOfClass:[NSArray class]]
            && model.data.count > 0)
        {
            [_transactionDetailView endFooterRefreshWithNoMoreDataStatus:NO];
        }
        else
        {
            [_transactionDetailView endFooterRefreshWithNoMoreDataStatus:YES];
        }
    }
    
    if (model.data
        && [model.data isKindOfClass:[NSArray class]])
    {
        [_arrayDS addObjectsFromArray:model.data];
    }
    
    if (_arrayDS.count <= 0)
    {
        [self showNoDataIn:_transactionDetailView
                   imgName:@"nodata_datas"
                     frame:self.view.frame
                     Title:@"啊哦~暂时没有数据~"
               buttonTitle:nil
                     Block:nil];
    }
    else
    {
        [self removeNoDataView];
        
        [_transactionDetailView tableViewReload];
    }
}

- (void)updateRequestFailureUI
{
    if (!_isLoadMore)
    {
        [_transactionDetailView endHeaderRefreshStatus];
    }
    else
    {
        [_transactionDetailView endFooterRefreshWithNoMoreDataStatus:NO];
    }
    
    __weak ESTransactionDetailView *weakListView = _transactionDetailView;
    [self showNoDataIn:_transactionDetailView
               imgName:@"nodata_net"
                 frame:self.view.frame
                 Title:@"网络有问题\n刷新一下试试吧"
           buttonTitle:@"刷新"
                 Block:^
     {
         [weakListView beginRefreshing];
     }];
}

#pragma mark - ESTransactionDetailViewDelegate
- (NSInteger)getTransactionDetailRowsWithSection:(NSInteger)section
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

#pragma mark - ESTransactionDetailCellDelegate
- (ESTransactionDetailModel *)getDetailDataWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _arrayDS.count)
    {
        return _arrayDS[indexPath.row];
    }
    
    return nil;
}

#pragma mark - Super Method
- (void)tapOnLeftButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
