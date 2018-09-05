
#import "ESModelSearcHistoryView.h"
#import "ESModelSearcHistoryCleanCell.h"
#import "ESModelSearcHistoryItemCell.h"

@interface ESModelSearcHistoryView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESModelSearcHistoryView
{
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 60.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.separatorColor = [UIColor stec_lineGrayColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerNib:[UINib nibWithNibName:@"ESModelSearcHistoryCleanCell" bundle:nil]
     forCellReuseIdentifier:@"ESModelSearcHistoryCleanCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESModelSearcHistoryItemCell" bundle:nil]
     forCellReuseIdentifier:@"ESModelSearcHistoryItemCell"];
    [self addSubview:_tableView];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getModelSearchHistoryRowsCount)])
    {
        row = [self.viewDelegate getModelSearchHistoryRowsCount];
    }
    return row;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        static NSString *cleanCellID = @"ESModelSearcHistoryCleanCell";
        ESModelSearcHistoryCleanCell *cell = [tableView dequeueReusableCellWithIdentifier:cleanCellID forIndexPath:indexPath];
        cell.cellDelegate = (id)self.viewDelegate;
        [cell updateCellWithIndexPath:indexPath];
        return cell;
    }
    
    static NSString *itemCellId = @"ESModelSearcHistoryItemCell";
    ESModelSearcHistoryItemCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellId forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(historyItemDidTapped:)])
    {
        [self.viewDelegate historyItemDidTapped:indexPath];
    }
}

#pragma mark - Public Method
- (void)refreshHistory
{
    [_tableView reloadData];
}

@end
