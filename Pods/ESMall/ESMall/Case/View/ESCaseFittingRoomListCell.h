
#import <UIKit/UIKit.h>

@class ESFittingSampleRoomModel;
@protocol ESCaseFittingRoomListCellDelegate <NSObject>

- (ESFittingSampleRoomModel *)getFittingRoomListCellDataWithIndex:(NSIndexPath *)indexPath;

@end

@interface ESCaseFittingRoomListCell : UITableViewCell

@property (nonatomic, assign) id<ESCaseFittingRoomListCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
