
#import "ESProductDetailView.h"
#import <WebKit/WebKit.h>
#import "MJRefresh.h"
#import "ESProductDetailBottomButton.h"
#import "ESProductDetailHeaderView.h"
#import "ESProductBaseCell.h"
#import <ESBasic/ESDevice.h>

@interface ESProductDetailView ()
<
UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate
>

@end

@implementation ESProductDetailView
{
    UIScrollView *_scrollView;
    UIScrollView *_scrollProductView;
    
    UITableView *_productTableView;
    WKWebView *_webProductView;
    WKWebView *_webView;
    UITableView *_parametersTableView;
    
    ESProductDetailBottomButton *_bottomButton;
    
    NSMutableDictionary *_dictCellIDs;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initProductDetailTView];
    }
    return self;
}

- (void)initProductDetailTView
{
    // 滚动视图
    CGFloat bottomButtonHeight = TABBAR_HEIGHT+BOTTOM_SAFEAREA_HEIGHT;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
                                                                 0,
                                                                 0,
                                                                 CGRectGetWidth(self.frame),
                                                                 CGRectGetHeight(self.frame) - bottomButtonHeight)];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(
                                         CGRectGetWidth(_scrollView.frame) * 3,
                                         CGRectGetHeight(_scrollView.frame)
                                         );
    [self addSubview:_scrollView];

    // 商品页
    _scrollProductView = [[UIScrollView alloc] initWithFrame:CGRectMake(
                                                                        0,
                                                                        0,
                                                                        CGRectGetWidth(_scrollView.frame),
                                                                        CGRectGetHeight(_scrollView.frame)
                                                                        )];
    _scrollProductView.showsVerticalScrollIndicator = NO;
    _scrollProductView.showsHorizontalScrollIndicator = NO;
    _scrollProductView.pagingEnabled = YES;
    _scrollProductView.bounces = NO;
    _scrollProductView.scrollEnabled = NO;
    _scrollProductView.contentSize = CGSizeMake(
                                         CGRectGetWidth(_scrollView.frame),
                                         CGRectGetHeight(_scrollView.frame) * 2
                                         );
    [_scrollView addSubview:_scrollProductView];
    
    _productTableView = [[UITableView alloc] initWithFrame:_scrollProductView.bounds];
    _productTableView.delegate = self;
    _productTableView.dataSource = self;
    _productTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _productTableView.estimatedRowHeight = 60.0;
    _productTableView.rowHeight = UITableViewAutomaticDimension;
    _productTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                             refreshingAction:@selector(productTableFooterDidUpdate)];
    footer.arrowView.image = [UIImage imageNamed:@"dropdown"];
    [footer setTitle:@"上拉查看图文详情"
            forState:MJRefreshStateIdle];
    [footer setTitle:@"释放查看图文详情"
            forState:MJRefreshStatePulling];
    [self setMjTitleVisualWithMjView:footer];
    _productTableView.mj_footer = footer;
    [_scrollProductView addSubview:_productTableView];
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController * wkUController = [[WKUserContentController alloc] init];
    // 自适应屏幕宽度js
    NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString
                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                     forMainFrameOnly:YES];
    // 添加自适应屏幕宽度js调用的方法
    [wkUController addUserScript:wkUserScript];
    webConfig.userContentController = wkUController;
    _webProductView = [[WKWebView alloc] initWithFrame:CGRectMake(0,
                                                           CGRectGetHeight(_scrollProductView.frame),
                                                           CGRectGetWidth(_scrollProductView.frame),
                                                           CGRectGetHeight(_scrollProductView.frame)
                                                           )
                                  configuration:webConfig];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(webViewHeaderDidPull)];
    [header setTitle:@"下拉查看商品"
            forState:MJRefreshStateIdle];
    [header setTitle:@"释放查看商品"
            forState:MJRefreshStatePulling];
    header.arrowView.image = [UIImage imageNamed:@"dropdown"];
    [self setMjTitleVisualWithMjView:header];
    header.lastUpdatedTimeLabel.hidden = YES;
    _webProductView.scrollView.mj_header = header;
    [_scrollProductView addSubview:_webProductView];

    
    // 详情页
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame),
                                                           0,
                                                           CGRectGetWidth(_scrollView.frame),
                                                           CGRectGetHeight(_scrollView.frame)
                                                           )
                                  configuration:webConfig];
    [_scrollView addSubview:_webView];
    
    // 参数页
    _parametersTableView = [[UITableView alloc]
                            initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) * 2,
                                                     0,
                                                     CGRectGetWidth(_scrollView.frame),
                                                     CGRectGetHeight(_scrollView.frame)
                                                     )];
    _parametersTableView.delegate = self;
    _parametersTableView.dataSource = self;
    _parametersTableView.backgroundColor = [UIColor stec_viewBackgroundColor];
    _parametersTableView.estimatedRowHeight = 60.0;
    _parametersTableView.rowHeight = UITableViewAutomaticDimension;
    _parametersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollView addSubview:_parametersTableView];
    
    // 底部按钮
    CGRect bottomRect = CGRectMake(
                                   0,
                                   CGRectGetHeight(self.frame)-bottomButtonHeight,
                                   CGRectGetWidth(self.frame),
                                   bottomButtonHeight
                                   );
    _bottomButton = [[ESProductDetailBottomButton alloc] initWithFrame:bottomRect];
    [self addSubview:_bottomButton];
}

#pragma mark - MJRefresh Method
- (void)webViewHeaderDidPull
{
    _scrollView.scrollEnabled = YES;
    
    [_webProductView.scrollView.mj_header endRefreshing];
    
    [_scrollProductView scrollRectToVisible:CGRectMake(
                                                       0,
                                                       0,
                                                       CGRectGetWidth(_scrollProductView.frame),
                                                       CGRectGetHeight(_productTableView.frame)
                                                       )
                                   animated:YES];
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(productDescriptionViewDidPull)])
    {
        [self.viewDelegate productDescriptionViewDidPull];
    }
}

- (void)productTableFooterDidUpdate
{
    _scrollView.scrollEnabled = NO;
    
    [_productTableView.mj_footer endRefreshing];
    
    [_scrollProductView scrollRectToVisible:CGRectMake(
                                                       0,
                                                       CGRectGetHeight(_productTableView.frame),
                                                       CGRectGetWidth(_webProductView.frame),
                                                       CGRectGetHeight(_webProductView.frame))
                                   animated:YES];
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(productInformationViewDidUpdate)])
    {
        [self.viewDelegate productInformationViewDidUpdate];
    }
}

- (void)setMjTitleVisualWithMjView:(UIView *)mjView
{
    if ([mjView isKindOfClass:[MJRefreshNormalHeader class]]
        || [mjView isKindOfClass:[MJRefreshBackNormalFooter class]])
    {
        MJRefreshNormalHeader *header = (id)mjView;
        [header.stateLabel setValue:[UIFont stec_remarkTextFount]
                             forKey:@"font"];
        [header.stateLabel setValue:[UIColor stec_subTitleTextColor]
                             forKey:@"textColor"];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger section = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(numberOfSectionsInProductViewWithType:)])
    {
        ESProductDetailSegControlType type = ESProductDetailSegControlTypeUnknow;
        if (tableView == _productTableView)
        {
            type = ESProductDetailSegControlTypeProduct;
        }
        else
        {
            type = ESProductDetailSegControlTypeParameters;
        }
        section = [self.viewDelegate numberOfSectionsInProductViewWithType:type];
    }
    return section;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(numberOfRowsInProductViewWithSection:type:)])
    {
        ESProductDetailSegControlType type = ESProductDetailSegControlTypeUnknow;
        if (tableView == _productTableView)
        {
            type = ESProductDetailSegControlTypeProduct;
        }
        else
        {
            type = ESProductDetailSegControlTypeParameters;
        }
        row = [self.viewDelegate numberOfRowsInProductViewWithSection:section type:type];
    }
    return row;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _productTableView)
    {
        BOOL showModelStatus = NO;
        if (self.viewDelegate
            && [self.viewDelegate respondsToSelector:@selector(getShowModelStatus)])
        {
            showModelStatus = [self.viewDelegate getShowModelStatus];
        }
        
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            return SCREEN_WIDTH;
        }
        else if (indexPath.section == 4 && indexPath.row == 0)
        {
            if (showModelStatus)
            {
                return 10 + (SCREEN_WIDTH - 16 * 2) * (420.3f/667.0f) + 18 + 21 + 18 + 25 + 10;
            }
        }
        else if (indexPath.section == 6)
        {
            return ((SCREEN_WIDTH - 20 * 2 - 12 * 3)/4.0f + 16) * 4 + 12 * 3 + 20 * 4 + 20;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _productTableView)
    {
        if (section == 6)
        {
            return 66.0f;
        }
        return 0.01f;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _productTableView)
    {
        if (section == 6)
        {
            ESProductDetailHeaderView *view = [ESProductDetailHeaderView productDetailHeaderView];
            view.frame = CGRectZero;
            view.headerDelegate = (id)self.viewDelegate;
            [view updateHeaderAtIndex:section];
            return view;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        view.backgroundColor = [UIColor stec_viewBackgroundColor];
        return view;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(getCellIDAtIndexPath:tableType:)])
    {
        ESProductDetailTableType tableType = ESProductDetailTableTypeUnKnow;
        tableType = (tableView == _productTableView)?ESProductDetailTableTypeProduct:ESProductDetailTableTypeParameters;
        NSString *cellID = [self.viewDelegate getCellIDAtIndexPath:indexPath
                                                         tableType:tableType];
        if (cellID
            && [cellID isKindOfClass:[NSString class]])
        {
            ESProductBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID
                                                                      forIndexPath:indexPath];
            cell.cellDelegate = (id)self.viewDelegate;
            [cell updateCellAtIndexPath:indexPath];
            return cell;
        }
    }

    SHLog(@"代理未设置");
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UITableView class]]
        || [scrollView isKindOfClass:[WKWebView class]])
    {
        return;
    }
    
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(scrollDidEndDragingWithIndex:)])
    {
        NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame);
        SHLog(@"停止滚动第:%ld页", index);
        [self.viewDelegate scrollDidEndDragingWithIndex:index];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _productTableView)
    {
        CGFloat sectionHeaderHeight = 66.0f;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
        else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame);
//    SHLog(@"停止拖拽%ld", index);
//    
//    if (!decelerate)
//    {
//        if (self.viewDelegate &&
//            [self.viewDelegate respondsToSelector:@selector(scrollDidEndDragingWithIndex:)])
//        {
//            NSInteger index = scrollView.contentOffset.x/CGRectGetWidth(_scrollView.frame);
//            SHLog(@"冬至拖拽%ld", index);
//
//            [self.viewDelegate scrollDidEndDragingWithIndex:index];
//        }
//    }
//}

#pragma mark - Public Methods
- (void)updateProductDetailViewWithType:(ESProductDetailSegControlType)type
{
    NSInteger index = type - 1;
    [_scrollView scrollRectToVisible:CGRectMake(
                                                CGRectGetWidth(_scrollView.frame) * index,
                                                0,
                                                CGRectGetWidth(_scrollView.frame),
                                                CGRectGetHeight(_scrollView.frame)
                                                )
                            animated:YES];
}

- (void)refreshProductDetailView
{
    [_productTableView reloadData];
    [_parametersTableView reloadData];
    [_webView reload];
    [_bottomButton updateBottomButtons];

    if ([self.viewDelegate respondsToSelector:@selector(getProductDetailHtmlStr)])
    {
        NSString *htmlStr = [self.viewDelegate getProductDetailHtmlStr];
        if (htmlStr
            && [htmlStr isKindOfClass:[NSString class]])
        {
            [_webProductView loadHTMLString:htmlStr baseURL:[NSURL URLWithString:htmlStr]];
            [_webView loadHTMLString:htmlStr baseURL:[NSURL URLWithString:htmlStr]];
        }
        
    }
}


- (void)refreshProductDetailTableViewWithSection:(NSInteger)index
{
    // 解决iOS 11,header 错位的问题
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.6f)
//    {
//        for (UIView *view in _productTableView.subviews)
//        {
//            if ([view isKindOfClass:[ESProductDetailHeaderView class]])
//            {
//                [view removeFromSuperview];
//            }
//        }
//    }
    
    // 动画展开
    [_productTableView reloadSections:[NSIndexSet indexSetWithIndex:index]
                     withRowAnimation:UITableViewRowAnimationFade];
    
    NSInteger section = index;
    BOOL status = YES;
    while (status)
    {
        NSInteger rowCount = [_productTableView numberOfRowsInSection:section];
        if (rowCount > 0)
        {
            [_productTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                     atScrollPosition:UITableViewScrollPositionTop
                                             animated:YES];
            status = NO;
        }
        else
        {
            section--;
        }
    }
}

#pragma Mark - Setter
- (void)setViewDelegate:(id<ESProductDetailViewDelegate>)viewDelegate
{
    _viewDelegate = viewDelegate;
    
    // 签订底部按钮代理
    _bottomButton.buttonDelegate = (id)_viewDelegate;
    
    // _productTableView注册Cell类型
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(registerCellAtTableView:type:)])
    {
        [self.viewDelegate registerCellAtTableView:_productTableView
                                              type:ESProductDetailTableTypeProduct];
    }
    
    // _parametersTableView注册Cell类型
    if (self.viewDelegate
        && [self.viewDelegate respondsToSelector:@selector(registerCellAtTableView:type:)])
    {
        [self.viewDelegate registerCellAtTableView:_parametersTableView
                                              type:ESProductDetailTableTypeParameters];
    }
}

- (void)updateBottomButton
{
    [_bottomButton updateBottomButtons];
}

@end
