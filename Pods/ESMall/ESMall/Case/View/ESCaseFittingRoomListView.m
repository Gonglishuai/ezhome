
#import "ESCaseFittingRoomListView.h"
#import "ESCaseFittingRoomListCell.h"
#import "MJRefresh.h"
#import "ESCaseFittingRoomListTitleView.h"
#import "ESFittingSampleModel.h"

#define SCROLL_IMAGE_VIEW_HEIGHT SCREEN_WIDTH * (401/750.0f)

@interface ESCaseFittingRoomListView ()
<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate
>

@end

@implementation ESCaseFittingRoomListView
{
    UITableView *_tableView;
    UIImageView *_scrollImageView;
    ESCaseFittingRoomListTitleView *_titleView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createFittingRoomListView];
    }
    return self;
}

- (void)createFittingRoomListView
{
    [self initTableView];
    
    [self addHeaderView];
    
    [self addRefresh];
}

- (void)initTableView
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 100.0f;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    [self addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"ESCaseFittingRoomListCell" bundle:[ESMallAssets hostBundle]]
     forCellReuseIdentifier:@"ESCaseFittingRoomListCell"];
}

- (void)addHeaderView
{
    _tableView.contentInset = UIEdgeInsetsMake(SCROLL_IMAGE_VIEW_HEIGHT, 0, 0, 0);
    _scrollImageView = [[UIImageView alloc] initWithFrame: CGRectMake(
                                                                      0,
                                                                      -SCROLL_IMAGE_VIEW_HEIGHT,
                                                                      SCREEN_WIDTH,
                                                                      SCROLL_IMAGE_VIEW_HEIGHT
                                                                      )];
    _scrollImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_tableView insertSubview:_scrollImageView atIndex:0];
    
    _titleView = [ESCaseFittingRoomListTitleView caseFittingRoomListTitleView];
    _titleView.frame = CGRectMake(
                                  0,
                                  -SCROLL_IMAGE_VIEW_HEIGHT,
                                  SCREEN_WIDTH,
                                  SCROLL_IMAGE_VIEW_HEIGHT
                                  );
    _titleView.titleBottom.constant = SCROLL_IMAGE_VIEW_HEIGHT * (130/401.0f);
    _titleView.spaceView.clipsToBounds = YES;
    _titleView.spaceView.layer.cornerRadius = CGRectGetHeight(_titleView.spaceView.frame)/2.0f;
    [_tableView insertSubview:_titleView aboveSubview:_scrollImageView];
}

- (void)addRefresh
{
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                             refreshingAction:@selector(tableViewDidPush)];
    footer.arrowView.image = [UIImage imageNamed:@"dropdown"];
    [footer.stateLabel setValue:[UIFont stec_remarkTextFount]
                         forKey:@"font"];
    [footer.stateLabel setValue:[UIColor stec_subTitleTextColor]
                         forKey:@"textColor"];
    [footer setTitle:@"没有更多啦~" forState:MJRefreshStateNoMoreData];
    _tableView.mj_footer = footer;
    _tableView.mj_footer.automaticallyChangeAlpha = YES;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getFittingRoomListRowsAtSection:)])
    {
        rows = [self.viewDelegate getFittingRoomListRowsAtSection:section];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listCellID = @"ESCaseFittingRoomListCell";
    ESCaseFittingRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellID
                                                                      forIndexPath:indexPath];
    cell.cellDelegate = (id)self.viewDelegate;
    [cell updateCellWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(fittingCaseDidTappedWithIndex:)])
    {
        [self.viewDelegate fittingCaseDidTappedWithIndex:indexPath.row];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]])
    {
        CGPoint point = scrollView.contentOffset;
        if (point.y < -SCROLL_IMAGE_VIEW_HEIGHT)
        {
            CGRect rect = _scrollImageView.frame;
            rect.origin.y = point.y;
            rect.size.height = -point.y;
            _scrollImageView.frame = rect;
        }
        
        if (self.viewDelegate
            && [self.viewDelegate respondsToSelector:@selector(tableViewDidScrollWithY:)])
        {
            [self.viewDelegate tableViewDidScrollWithY:point.y];
        }
    }
}

#pragma mark - Public Methods
- (void)endFooterRefreshWithNoDataStatus:(BOOL)noData
{
    if (noData)
    {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
    else
    {
        [_tableView.mj_footer endRefreshing];
    }
}

#pragma mark - Methods
- (void)tableViewDidPush
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(fittingRoomListDidPush)])
    {
        [self.viewDelegate fittingRoomListDidPush];
    }
}

- (void)tableViewReload
{
    [_tableView reloadData];
}

- (void)updateHeaderView
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getHeaderData)])
    {
        ESFittingSampleModel *sampModel = [self.viewDelegate getHeaderData];
        if ([sampModel isKindOfClass:[ESFittingSampleModel class]])
        {
            _scrollImageView.image = [ESMallAssets bundleImage:sampModel.spaceimageName];
            _titleView.titleImageView.image = [ESMallAssets bundleImage:sampModel.spaceTitleIconName];
            
            // 主标题
            NSMutableAttributedString *attributedStringTitle = [[NSMutableAttributedString alloc] initWithString:sampModel.spaceTitle attributes:@{NSKernAttributeName:@(6)}];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [attributedStringTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [sampModel.spaceTitle length])];
            _titleView.titleLabel.attributedText = attributedStringTitle;
            
            // 副标题
            NSMutableAttributedString *attributedStringSubTitle = [[NSMutableAttributedString alloc] initWithString:sampModel.spaceSubTitle attributes:@{NSKernAttributeName:@(1)}];
            NSMutableParagraphStyle *subParagraphStyle = [[NSMutableParagraphStyle alloc] init];
            [attributedStringSubTitle addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle range:NSMakeRange(0, [sampModel.spaceSubTitle length])];
            _titleView.subTitleLabel.attributedText = attributedStringSubTitle;
        }
    }
}

@end
