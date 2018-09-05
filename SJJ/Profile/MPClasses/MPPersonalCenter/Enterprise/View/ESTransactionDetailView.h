
#import <UIKit/UIKit.h>

@protocol ESTransactionDetailViewDelegate <NSObject>

- (NSInteger)getTransactionDetailRowsWithSection:(NSInteger)section;

- (void)tableViewDidPull;

- (void)tableViewDidPush;

@end

@interface ESTransactionDetailView : UIView

@property (nonatomic, assign) id<ESTransactionDetailViewDelegate>viewDelegate;

/// reload tableview
- (void)tableViewReload;

/// 结束下拉刷新状态
- (void)endHeaderRefreshStatus;

/// 结束上拉刷新状态
- (void)endFooterRefreshWithNoMoreDataStatus:(BOOL)noMoreDataStatus;

/// 刷新
- (void)beginRefreshing;

@end
