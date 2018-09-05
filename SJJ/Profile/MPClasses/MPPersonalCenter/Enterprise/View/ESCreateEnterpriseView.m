
#import "ESCreateEnterpriseView.h"
#import "ESCreateEnterpriseBaseCell.h"

@interface ESCreateEnterpriseView ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ESCreateEnterpriseView
{
    UITableView *_tableView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createEnterpriseTableView];
    }
    return self;
}

- (void)createEnterpriseTableView
{
    self.backgroundColor = [UIColor stec_viewBackgroundColor];
    
    CGFloat buttonTopSpace = 10.0f;
    CGFloat buttonHeight = 43.0f;
    CGFloat buttonBottomSpace = 39.0f;
    CGRect tableViewFrame = CGRectMake(
                                       0,
                                       0,
                                       CGRectGetWidth(self.bounds),
                                       CGRectGetHeight(self.bounds) - buttonHeight- buttonBottomSpace - buttonTopSpace
                                       );
    _tableView = [[UITableView alloc] initWithFrame:tableViewFrame];
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESCreateTextFieldCell" bundle:nil]
     forCellReuseIdentifier:@"ESCreateTextFieldCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ESCreateButtonCell" bundle:nil]
     forCellReuseIdentifier:@"ESCreateButtonCell"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(
                              (CGRectGetWidth(self.bounds) - 148.0f)/2.0f,
                              CGRectGetHeight(self.bounds) - buttonHeight - buttonBottomSpace,
                              148.0f,
                              43.0f
                              );
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 43.0f/2.0f;
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor stec_blueTextColor]];
    [button addTarget:self
               action:@selector(completeButtonDidTapped:)
     forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger section = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getEnterpriseTableSection)])
    {
        section = [self.viewDelegate getEnterpriseTableSection];
    }
    
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getEnterpriseTableRowsWithSection:)])
    {
        row = [self.viewDelegate getEnterpriseTableRowsWithSection:section];
    }
    
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0f;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getEnterpriseTableRowHeight:)])
    {
        rowHeight = [self.viewDelegate getEnterpriseTableRowHeight:indexPath];
    }
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getItemTypeWithIndexPath:)])
    {
        NSString *itemType = [self.viewDelegate getItemTypeWithIndexPath:indexPath];
        if (itemType
            && [itemType isKindOfClass:[NSString class]])
        {
            NSString *cellId = nil;
            if ([itemType isEqualToString:@"button"])
            {
                static NSString *buttonCellID = @"ESCreateButtonCell";
                cellId = buttonCellID;
            }
            else if ([itemType isEqualToString:@"textfield"])
            {
                static NSString *tfCellID = @"ESCreateTextFieldCell";
                cellId = tfCellID;
            }
            else
            {
                SHLog(@"未知类型");
            }
            
            if (cellId)
            {
                ESCreateEnterpriseBaseCell *cell =
                [tableView dequeueReusableCellWithIdentifier:cellId
                                                forIndexPath:indexPath];
                cell.cellDelegate = (id)self.viewDelegate;
                [cell updateCellWithIndexPath:indexPath];
                return cell;
            }
        }
    }
    
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self endEditing:YES];
}

#pragma mark - Button Methos
- (void)completeButtonDidTapped:(UIButton *)button
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(completeButtonDidTapped)])
    {
    
        [self.viewDelegate completeButtonDidTapped];
    }
}

#pragma mark - Public Methods
- (void)tableViewReload
{
    [_tableView reloadData];
}

@end
