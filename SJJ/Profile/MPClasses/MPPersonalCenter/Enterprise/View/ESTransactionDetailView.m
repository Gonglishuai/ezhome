
#import "ESTransactionDetailView.h"
#import "ESTransactionDetailCell.h"
#import "ESDiyRefreshHeader.h"

@interface ESTransactionDetailView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESTransactionDetailView
{
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createTransactionDetailTableView];
        
        [self addRefresh];
    }
    return self;
}

- (void)createTransactionDetailTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESTransactionDetailCell" bundle:nil]
     forCellReuseIdentifier:@"ESTransactionDetailCell"];
    [self addSubview:_tableView];
}

- (void)addRefresh
{
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(tableViewDidPull)];
    _tableView.mj_header = header;
    
//    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
//                                                                             refreshingAction:@selector(tableViewDidPush)];
//    footer.arrowView.image = [UIImage imageNamed:@"dropdown"];
//    [footer.stateLabel setValue:[UIFont stec_remarkTextFount]
//                         forKey:@"font"];
//    [footer.stateLabel setValue:[UIColor stec_subTitleTextColor]
//                         forKey:@"textColor"];
//    [footer setTitle:@"没有更多啦~" forState:MJRefreshStateNoMoreData];
//    _tableView.mj_footer = footer;
    
    _tableView.mj_header.automaticallyChangeAlpha = YES;
//    _tableView.mj_footer.automaticallyChangeAlpha = YES;
}

- (void)tableViewDidPull
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(tableViewDidPull)])
    {
        [self.viewDelegate tableViewDidPull];
    }
}

- (void)tableViewDidPush
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(tableViewDidPush)])
    {
        [self.viewDelegate tableViewDidPush];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getTransactionDetailRowsWithSection:)])
    {
        rows = [self.viewDelegate getTransactionDetailRowsWithSection:section];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ESTransactionDetailCell";
    ESTransactionDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                  forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}

#pragma mark - Public Method
- (void)tableViewReload
{
    [_tableView reloadData];
}

- (void)endHeaderRefreshStatus
{
    [_tableView.mj_header endRefreshing];
    [_tableView.mj_footer resetNoMoreData];
}

- (void)endFooterRefreshWithNoMoreDataStatus:(BOOL)noMoreDataStatus
{
    if (noMoreDataStatus)
    {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
    else
    {
        [_tableView.mj_footer endRefreshing];
    }
}

- (void)beginRefreshing
{
    [_tableView.mj_header beginRefreshing];
}

@end
