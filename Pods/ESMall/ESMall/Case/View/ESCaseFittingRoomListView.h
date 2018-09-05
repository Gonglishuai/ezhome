
#import <UIKit/UIKit.h>

@class ESFittingSampleModel;
@protocol ESCaseFittingRoomListViewDelegate <NSObject>

- (NSInteger)getFittingRoomListRowsAtSection:(NSInteger)section;

- (void)fittingRoomListDidPush;

- (void)tableViewDidScrollWithY:(CGFloat)y;

- (ESFittingSampleModel *)getHeaderData;

- (void)fittingCaseDidTappedWithIndex:(NSInteger)index;

@end

@interface ESCaseFittingRoomListView : UIView

@property (nonatomic, assign) id<ESCaseFittingRoomListViewDelegate>viewDelegate;

- (void)endFooterRefreshWithNoDataStatus:(BOOL)noData;

- (void)tableViewReload;

- (void)updateHeaderView;

@end
