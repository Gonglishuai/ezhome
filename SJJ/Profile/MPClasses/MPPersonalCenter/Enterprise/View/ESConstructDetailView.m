
#import "ESConstructDetailView.h"
#import "ESConstructDetailCell.h"

@interface ESConstructDetailView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESConstructDetailView
{
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createConstructDetailTableView];
    }
    return self;
}

- (void)createConstructDetailTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50.0f;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESConstructDetailCell" bundle:nil]
     forCellReuseIdentifier:@"ESConstructDetailCell"];
    [self addSubview:_tableView];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getConstructDetailSections)])
    {
        sections = [self.viewDelegate getConstructDetailSections];
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getConstructDetailRowsWithSection:)])
    {
        rows = [self.viewDelegate getConstructDetailRowsWithSection:section];
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ESConstructDetailCell";
    ESConstructDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
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

#pragma mark - Public Method
- (void)tableViewReload
{
    [_tableView reloadData];
}

@end
