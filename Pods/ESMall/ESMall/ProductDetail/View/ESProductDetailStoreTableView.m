
#import "ESProductDetailStoreTableView.h"
#import "Masonry.h"
#import "ESProductDetailStoreHeaderView.h"

@implementation ESProductDetailStoreTableView
{
    ESProductDetailStoreHeaderView *_headerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createTableView];
    }
    return self;
}

- (void)createTableView
{
    CGFloat headerHeight = 40.0f;
    self.tableView = [[UITableView alloc] init];
    [self addSubview:_tableView];
    
    CGRect headerFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), headerHeight);
    ESProductDetailStoreHeaderView *headerView = [[ESProductDetailStoreHeaderView alloc] initWithFrame:headerFrame];
    [self addSubview:headerView];
    
    _headerView = headerView;
    
    __weak typeof (self) weakSelf = self;
    __weak ESProductDetailStoreHeaderView *weakHeader = headerView;
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(headerHeight);
        make.left.equalTo(weakSelf.mas_left);
        make.top.equalTo(weakSelf.mas_top);
        make.right.equalTo(weakSelf.mas_right);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakHeader.mas_bottom);
        make.left.equalTo(weakSelf.mas_left);
        make.right.equalTo(weakSelf.mas_right);
        make.bottom.equalTo(weakSelf.mas_bottom);
    }];
}

- (void)setViewDelegate:(id<ESProductDetailStoreTableViewDelegate>)viewDelegate
{
    _viewDelegate = viewDelegate;
    
    _headerView.headerDelegate = (id)viewDelegate;
}

@end
