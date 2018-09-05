//
//  MPHome3dview.m
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "MPHome3dview.h"
#import "MPHome3DViewCell.h"
#import "MJRefresh.h"
#import "ESDiyRefreshHeader.h"

@interface MPHome3dview () <UICollectionViewDataSource, UICollectionViewDelegate>

@end
@implementation MPHome3dview
{
    UIImageView *_emptyView;    //!< _emptyView the view will show when request data.
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor whiteColor];
    [self createCollectionView];
    [self addRefresh];
    return self;
}


- (void)createCollectionView
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, SCREEN_WIDTH * CASE_IMAGE_RATIO + 40);
    flowLayout.sectionInset = UIEdgeInsetsZero;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _home3DCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height) collectionViewLayout:flowLayout];
    _home3DCollectionView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
    [self addSubview:_home3DCollectionView];
    _home3DCollectionView.delegate = self;
    _home3DCollectionView.dataSource = self;
    _home3DCollectionView.showsVerticalScrollIndicator = NO;
    _home3DCollectionView.backgroundColor = COLOR(238, 241, 244, 1);
    [_home3DCollectionView registerNib:[UINib nibWithNibName:@"MPHome3DViewCell" bundle:nil] forCellWithReuseIdentifier:@"MPHome3DViewCell"];
    _home3DCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _emptyView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2 - 95, (150/375.0) * SCREEN_WIDTH, 190, 59)];
    _emptyView.image = [UIImage imageNamed:HOME_CASE_EMPTY_IMAGE];
    [_home3DCollectionView addSubview:_emptyView];
    
    
}

/// add refresh load more data & load new data
- (void)addRefresh {
    WS(weakSelf);
    /// add head refresh.
    _home3DCollectionView.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refresh3DLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate refresh3DLoadNewData:^() {
                [weakSelf endHeaderRefresh];
                [weakSelf refresh3DHomeCaseView];

            }];
        }
    }];
    _home3DCollectionView.mj_header.automaticallyChangeAlpha = YES;
    
    _home3DCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(refresh3DLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate refresh3DLoadMoreData:^() {
                [weakSelf endFooterRefresh];
                [weakSelf refresh3DHomeCaseView];
            }];
        }
    }];
    [_home3DCollectionView.mj_header beginRefreshing];
}
- (void)startMJRefreshHeader {
    [_home3DCollectionView.mj_header beginRefreshing];
}
/// end header refresh
- (void)endHeaderRefresh {
    [_home3DCollectionView.mj_header endRefreshingWithCompletionBlock:^{
        [_home3DCollectionView setContentOffset:CGPointZero animated:YES];
    }];

}

/// end footer refresh
- (void)endFooterRefresh {
    [_home3DCollectionView.mj_footer endRefreshing];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate get3DNumberOfItemsInCollection];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MPHome3DViewCell* cell = (MPHome3DViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"MPHome3DViewCell" forIndexPath:indexPath];
    cell.delegate = (id)self.delegate;
    
    [cell update3DCellUIForIndex:indexPath.item];
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

- (void)refresh3DHomeCaseView {
    if (_emptyView)
        [_emptyView removeFromSuperview];
    
    [_home3DCollectionView reloadData];
}

@end
