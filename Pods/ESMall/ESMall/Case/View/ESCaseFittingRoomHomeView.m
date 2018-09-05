
#import "ESCaseFittingRoomHomeView.h"
#import "ESCaseFittingRoomHomeHeaderCell.h"
#import "ESCaseFittingRoomHomeCell.h"
#import "ESDiyRefreshHeader.h"

@interface ESCaseFittingRoomHomeView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESCaseFittingRoomHomeView
{
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createFilttingView];
    }
    return self;
}

- (void)createFilttingView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 100.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseFittingRoomHomeCell" bundle:[ESMallAssets hostBundle]]
     forCellReuseIdentifier:@"ESCaseFittingRoomHomeCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseFittingRoomHomeHeaderCell" bundle:[ESMallAssets hostBundle]]
     forCellReuseIdentifier:@"ESCaseFittingRoomHomeHeaderCell"];
    
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(tableViewDidPull)];
    _tableView.mj_header = header;
    _tableView.mj_header.automaticallyChangeAlpha = YES;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getFittingRoomTableViewRowsAtSection:)])
    {
        rowCount = [self.viewDelegate getFittingRoomTableViewRowsAtSection:section];
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return SCREEN_WIDTH * (250/750.0f) + 10.0f;
    }
    
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *loopCellId = @"ESCaseFittingRoomHomeHeaderCell";
        ESCaseFittingRoomHomeHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:loopCellId
                                                                                forIndexPath:indexPath];
        cell.cellDelegate = (id)self.viewDelegate;
        [cell updateCellWithIndexPath:indexPath];
        return cell;
    }
    
    static NSString *fittingRoomCellId = @"ESCaseFittingRoomHomeCell";
    ESCaseFittingRoomHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:fittingRoomCellId
                                                                      forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}


#pragma mark - Public Methods
- (void)beginRefresh
{
    [_tableView.mj_header beginRefreshing];
}

- (void)endHeaderRefresh
{
    [_tableView.mj_header endRefreshing];
}

- (void)tableViewReload
{
    [_tableView reloadData];
}

#pragma mark - Methods
- (void)tableViewDidPull
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(fittingRoomHomeDidPull)])
    {
        [self.viewDelegate fittingRoomHomeDidPull];
    }
}

@end
