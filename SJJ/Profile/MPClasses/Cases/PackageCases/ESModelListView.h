
#import <UIKit/UIKit.h>

@protocol ESModelListViewDelegate <NSObject>

- (NSInteger)getModelCount;

- (void)cellDidTappedWithIndexPath:(NSIndexPath *)indexPath;

- (void)tableViewDidPull;

- (void)tableViewDidPush;

@end

@interface ESModelListView : UIView

@property (nonatomic, assign) id<ESModelListViewDelegate>viewDelegate;

@property (nonatomic, assign) BOOL searchStatus;

/// 结束下拉刷新状态
- (void)endHeaderRefreshStatus;

/// 结束上拉刷新状态
- (void)endFooterRefreshWithNoMoreDataStatus:(BOOL)noMoreDataStatus;

/// reload tableview
- (void)tableViewReload;

/// 滚动到最上边
- (void)tableviewScrollToTop;

/// 底部展示数据数量的label
- (void)showCountToast:(NSString *)count;

/// 刷新
- (void)beginRefreshing;

@end
