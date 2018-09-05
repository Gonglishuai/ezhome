
#import <UIKit/UIKit.h>

@protocol ESCaseFittingRoomHomeViewDelegate <NSObject>

- (NSInteger)getFittingRoomTableViewRowsAtSection:(NSInteger)section;

- (void)fittingRoomHomeDidPull;

@end

@interface ESCaseFittingRoomHomeView : UIView

@property (nonatomic, assign) id<ESCaseFittingRoomHomeViewDelegate>viewDelegate;

- (void)beginRefresh;

- (void)endHeaderRefresh;

- (void)tableViewReload;

@end
