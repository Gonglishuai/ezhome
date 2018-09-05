/**
 * @file    MPFindDesignersView.m
 * @brief   the view of find designer.
 * @author  Xue
 * @version 1.0
 * @date    2016-02-17
 */

#import "MPFindDesignersView.h"
#import "MPFindDesignersTableViewCell.h"
#import <Masonry.h>
#import "ESDiyRefreshHeader.h"

@implementation MPFindDesignersView
{
    UITableView *_findTabelview;          //!< list view of table.
    MPFindDesignersTableViewCell *_cell;  //!< the view for cell.
    UIImageView *_emptyView;              //!< _emptyView the view for no designers.
}
- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:233/255.0 green:233/255.0 blue:233/255.0 alpha:1];
        [self createFindView];

    }
    return self;
}
/// Create find designers view.
- (void)createFindView {
    
    _findTabelview = [[UITableView alloc] init];
    _findTabelview.delegate = self;
    _findTabelview.dataSource = self;
    [_findTabelview registerNib:[UINib nibWithNibName:@"MPFindDesignersTableViewCell" bundle:nil] forCellReuseIdentifier:@"MPFindDesigners"];
    _findTabelview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_findTabelview];
    
    _emptyView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)/2 - 95, (150/375.0) * SCREEN_WIDTH, 190, 59)];
    _emptyView.image = [UIImage imageNamed:HOME_CASE_EMPTY_IMAGE];
    [_findTabelview addSubview:_emptyView];
    
    [_findTabelview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [self addDesignerLibraryRefresh];
}

- (void)addDesignerLibraryRefresh {
    WS(weakSelf);
    _findTabelview.mj_header = [ESDiyRefreshHeader headerWithRefreshingBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(findDesignersViewRefreshLoadNewData:)]) {
            [weakSelf endFooterRefresh];
            [weakSelf.delegate findDesignersViewRefreshLoadNewData:^{
                [weakSelf endHeaderRefresh];
                [weakSelf refreshFindDesignersUI];
                
            }];
        }
    }];
    
    _findTabelview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([weakSelf.delegate respondsToSelector:@selector(findDesignersViewRefreshLoadMoreData:)]) {
            [weakSelf endHeaderRefresh];
            [weakSelf.delegate findDesignersViewRefreshLoadMoreData:^{
                [weakSelf endFooterRefresh];
                [weakSelf refreshFindDesignersUI];
            }];
        }
    }];
    [_findTabelview.mj_header beginRefreshing];
}

- (void)startMJRefreshHeader {
    [_findTabelview.mj_header beginRefreshing];
}
/// end header refresh
- (void)endHeaderRefresh {
    [_findTabelview.mj_header endRefreshingWithCompletionBlock:^{
        [_findTabelview setContentOffset:CGPointZero animated:YES];
    }];
}

/// end footer refresh
- (void)endFooterRefresh {
    [_findTabelview.mj_footer endRefreshing];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self.delegate respondsToSelector:@selector(getDesignerCellCount)])
        return [self.delegate getDesignerCellCount];
    
    return 0;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    _cell = [tableView dequeueReusableCellWithIdentifier:@"MPFindDesigners"];
    _cell.delegate = (id)self.delegate;
    [_cell updateCellForIndex:indexPath.row];
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 92.0f*SCREEN_SCALE;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)])
        [self.delegate didSelectItemAtIndex:indexPath.row];
}

#pragma mark- Public interface methods

-(void) refreshFindDesignersUI
{
    
    if (_emptyView)
        [_emptyView removeFromSuperview];
    [_findTabelview reloadData];
}

@end
