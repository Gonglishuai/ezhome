
#import <UIKit/UIKit.h>

@protocol ESReturnApplyWayCellDelegate <NSObject>

- (void)applyGoodsWithMoneyDidTapped;

- (void)applyMoneyDidTapped;

- (NSInteger)getReturnWayStatus;

@end

@interface ESReturnApplyWayCell : UITableViewCell

@property (nonatomic, assign) id<ESReturnApplyWayCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
