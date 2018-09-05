
#import "ESPayTimesView.h"
#import "ESPayBaseCell.h"

@interface ESPayTimesView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESPayTimesView
{
    UITableView *_tableView;
    UIButton *_payButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createPayTimesView];
    }
    return self;
}

- (void)createPayTimesView
{
    CGFloat bottomButtonHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT;
    CGRect tableViewFrame = CGRectMake(
                                       0,
                                       0,
                                       CGRectGetWidth(self.frame),
                                       CGRectGetHeight(self.frame) - bottomButtonHeight
                                       );
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 50.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"ESConstructDetailCell" bundle:[ESMallAssets hostBundle]]
     forCellReuseIdentifier:@"ESConstructDetailCell"];
    [self addSubview:_tableView];
    
    _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _payButton.frame = CGRectMake(
                                  0,
                                  CGRectGetHeight(self.frame) - bottomButtonHeight,
                                  CGRectGetWidth(self.frame),
                                  bottomButtonHeight
                                  );
    [_payButton setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
    [_payButton addTarget:self
                   action:@selector(payButtonDidTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    _payButton.titleLabel.font = [UIFont stec_buttonFount];
    _payButton.enabled = NO;
    [self addSubview:_payButton];
    if (BOTTOM_SAFEAREA_HEIGHT>0) {
        _payButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    }
    [self updatePayButton];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getPayViewRowsWithSection:)])
    {
        rows = [self.viewDelegate getPayViewRowsWithSection:section];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getCellIdWithIndexPath:)])
    {
        NSString *cellId = [self.viewDelegate getCellIdWithIndexPath:indexPath];
        if (cellId
            && [cellId isKindOfClass:[NSString class]])
        {
            ESPayBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId
                                                                  forIndexPath:indexPath];
            cell.tableView = tableView;
            cell.cellDelegate = (id)self.viewDelegate;
            [cell updateCellWithIndexPath:indexPath];
            if ([cellId isEqualToString:@"ESPayFinanceCollectionViewTableViewCell"]) {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }
    
    return [[ESPayBaseCell alloc] init];;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
}

#pragma mark - Public Method
- (void)tableViewReload
{
    [_tableView reloadData];
}

- (void)tableviewShowTextInputWithIndexPath:(NSIndexPath *)indexPath
                                 showStatus:(BOOL)showStatus
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSInteger sections = [_tableView numberOfSections];
    if (section < sections)
    {
        NSInteger rows = [_tableView numberOfRowsInSection:section];
        if (showStatus)
        {
            NSIndexPath *showIndexPath = [NSIndexPath indexPathForRow:row + 1
                                                            inSection:section];
            [_tableView insertRowsAtIndexPaths:@[showIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];

        }
        else
        {
            if (row + 1 < rows)
            {
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:row + 1
                                                                  inSection:section];
                [_tableView deleteRowsAtIndexPaths:@[deleteIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    else
    {
        [self tableViewReload];
    }
}

- (void)updateButtonWithAmount:(NSString *)amount
                        enable:(BOOL)enable
{
    _payButton.enabled = enable;
    [self updatePayButton];
    
    if (amount
        && [amount isKindOfClass:[NSString class]]
        && amount.length > 0)
    {
        NSString *title = [NSString stringWithFormat:@"确认支付：¥%@", amount];
        [_payButton setTitle:title
                    forState:UIControlStateNormal];
    }
}

#pragma mark - Setting
- (void)setViewDelegate:(id<ESPayTimesViewDelegate>)viewDelegate
{
    _viewDelegate = viewDelegate;
    
    [self regCells];
}

#pragma mark - Methods
- (void)regCells
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getRegCellNames)])
    {
        NSArray *cells = [self.viewDelegate getRegCellNames];
        if (!cells
            || ![cells isKindOfClass:[NSArray class]])
        {
            return;
        }
        
        for (NSString *cellName in cells)
        {
            if ([cellName isKindOfClass:[NSString class]])
            {
                [_tableView registerNib:[UINib nibWithNibName:cellName bundle:[ESMallAssets hostBundle]]
                 forCellReuseIdentifier:cellName];
            }
        }
    }
}

- (void)updatePayButton
{
    UIColor *backgroundColor = nil;
    if (_payButton.enabled)
    {
        backgroundColor = [UIColor stec_blueTextColor];
    }
    else
    {
        backgroundColor = [UIColor stec_grayBackgroundTextColor];
    }
    _payButton.backgroundColor = backgroundColor;
}

#pragma mark - Button Method
- (void)payButtonDidTapped:(UIButton *)button
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(payButtonDidTapped)])
    {
        [self.viewDelegate payButtonDidTapped];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self endEditing:YES];
}

@end
