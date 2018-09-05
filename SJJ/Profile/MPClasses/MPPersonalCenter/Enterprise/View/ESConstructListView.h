
#import <UIKit/UIKit.h>

@protocol ESConstructListViewDelegate <NSObject>

- (NSInteger)getConstructListRowsWithSection:(NSInteger)section;

- (void)tableViewDidPull;

- (void)tableViewDidPush;

@end

@interface ESConstructListView : UIView

@property (nonatomic, assign) id<ESConstructListViewDelegate>viewDelegate;

/// reload tableview
- (void)constructTableViewReload;

/// 结束下拉刷新状态
- (void)endHeaderRefreshStatus;

/// 结束上拉刷新状态
- (void)endFooterRefreshWithNoMoreDataStatus:(BOOL)noMoreDataStatus;

/// 刷新
- (void)beginRefreshing;

@end
