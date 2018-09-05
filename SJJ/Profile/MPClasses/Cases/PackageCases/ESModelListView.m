
#import "ESModelListView.h"
#import "ESModelListCell.h"
#import "ESModelSearchCell.h"
#import "ESDiyRefreshHeader.h"

@interface ESModelListView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESModelListView
{
    UITableView *_tableView;
    UILabel *_countLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
        
        [self addRefresh];
    }
    return self;
}

- (void)initUI
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 100.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESModelListCell" bundle:nil]
     forCellReuseIdentifier:@"ESModelListCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESModelSearchCell" bundle:nil]
     forCellReuseIdentifier:@"ESModelSearchCell"];
    [self addSubview:_tableView];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];;
    _countLabel.font = [UIFont stec_subTitleFount];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.backgroundColor = [UIColor stec_titleTextColor];
    _countLabel.alpha = 0.8f;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.clipsToBounds = YES;
    _countLabel.layer.cornerRadius = 3.0f;
    [self addSubview:_countLabel];
    
    [self sendSubviewToBack:_countLabel];
}

- (void)addRefresh
{
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(tableViewDidPull)];
    _tableView.mj_header = header;
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                             refreshingAction:@selector(tableViewDidPush)];
    footer.arrowView.image = [UIImage imageNamed:@"dropdown"];
    [footer.stateLabel setValue:[UIFont stec_remarkTextFount]
                         forKey:@"font"];
    [footer.stateLabel setValue:[UIColor stec_subTitleTextColor]
                         forKey:@"textColor"];
    [footer setTitle:@"没有更多啦~" forState:MJRefreshStateNoMoreData];
    _tableView.mj_footer = footer;
    
    _tableView.mj_header.automaticallyChangeAlpha = YES;
    _tableView.mj_footer.automaticallyChangeAlpha = YES;
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
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getModelCount)])
    {
        NSInteger rowCount = [self.viewDelegate getModelCount];
        return rowCount;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && self.searchStatus)
    {
        static NSString *searchCellID = @"ESModelSearchCell";
        ESModelSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellID forIndexPath:indexPath];
        cell.cellDelegate = (id)self.viewDelegate;
        [cell updateSearchCellWithIndexPath:indexPath];
        return cell;
    }
    
    static NSString *cellID = @"ESModelListCell";
    ESModelListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                            forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(cellDidTappedWithIndexPath:)])
    {
        [self.viewDelegate cellDidTappedWithIndexPath:indexPath];
    }
}

#pragma Mark - Public Methods
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

- (void)tableViewReload
{
    [_tableView reloadData];
}

- (void)tableviewScrollToTop
{
    NSInteger sections = [_tableView numberOfSections];
    if (sections > 0)
    {
        NSInteger rowCount = [_tableView numberOfRowsInSection:0];
        if (rowCount > 0)
        {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
        }
    }
}

- (void)showCountToast:(NSString *)count
{
    if (!count
        || ![count isKindOfClass:[NSString class]])
    {
        return;
    }
    
    [self bringSubviewToFront:_countLabel];
    _countLabel.text = [NSString stringWithFormat:@"共%@条数据", count];
    [_countLabel sizeToFit];
    CGRect frame = _countLabel.frame;
    _countLabel.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + 10, 28.0f);
    [_countLabel setCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - _countLabel.frame.size.height / 2 - 30.0f)];
    [self performSelector:@selector(hideCountLabel) withObject:nil afterDelay:2];
}

- (void)beginRefreshing
{
    [_tableView.mj_header beginRefreshing];
}

#pragma Mark - Methods
- (void)hideCountLabel
{
    _countLabel.text = @"";
    [self sendSubviewToBack:_countLabel];
}

@end
