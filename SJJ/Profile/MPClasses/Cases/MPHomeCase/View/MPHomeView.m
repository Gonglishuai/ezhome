
#import "MPHomeView.h"
#import "MPHomeViewCell.h"
#import "ESDiyRefreshHeader.h"

@interface MPHomeView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation MPHomeView
{
    UIImageView *_emptyView;    //!< _emptyView the view will show when request data.
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
   
//    self.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
    self.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    
    return self;
}


- (void)createCollectionView
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, SCREEN_WIDTH * CASE_IMAGE_RATIO + 40);
    flowLayout.sectionInset = UIEdgeInsetsZero;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _homeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height) collectionViewLayout:flowLayout];
    _homeCollectionView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
    [self addSubview:_homeCollectionView];
    _homeCollectionView.delegate = self;
    _homeCollectionView.dataSource = self;
    _homeCollectionView.showsVerticalScrollIndicator = NO;
    _homeCollectionView.backgroundColor = [UIColor clearColor];
    [_homeCollectionView registerNib:[UINib nibWithNibName:@"MPHomeViewCell" bundle:nil] forCellWithReuseIdentifier:@"MPHomeViewCell"];
    _homeCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _emptyView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2 - 95, (150/375.0) * SCREEN_WIDTH, 190, 59)];
    _emptyView.image = [UIImage imageNamed:HOME_CASE_EMPTY_IMAGE];
    [_homeCollectionView addSubview:_emptyView];
    
    [self addRefresh];
}

/// add refresh load more data & load new data
- (void)addRefresh {
    WS(weakSelf);
    /// add head refresh.
    _homeCollectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate refreshLoadNewData:^() {
                [weakSelf endHeaderRefresh];
                [weakSelf refreshHomeCaseView];

            }];
        }
    }];
    _homeCollectionView.mj_header.automaticallyChangeAlpha = YES;
    
    _homeCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refreshLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate refreshLoadMoreData:^() {
                [weakSelf endFooterRefresh];
                [weakSelf refreshHomeCaseView];
            }];
        }
    }];
    [_homeCollectionView.mj_header beginRefreshing];
}
- (void)startMJRefreshHeader {
    [_homeCollectionView.mj_header beginRefreshing];
}
/// end header refresh
- (void)endHeaderRefresh {
    [_homeCollectionView.mj_header endRefreshingWithCompletionBlock:^{
        [_homeCollectionView setContentOffset:CGPointZero animated:YES];
    }];}

/// end footer refresh
- (void)endFooterRefresh {
    [_homeCollectionView.mj_footer endRefreshing];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate getNumberOfItemsInCollection];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MPHomeViewCell* cell = (MPHomeViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPHomeViewCell" forIndexPath:indexPath];
    cell.delegate = (id)self.delegate;
    [cell updateCellUIForIndex:indexPath.item ];
    return cell;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [self.delegate didSelectedItemAtIndex:indexPath.item];
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (void)refreshHomeCaseView {
    if (_emptyView)
        [_emptyView removeFromSuperview];
    
    [_homeCollectionView reloadData];
}

@end
