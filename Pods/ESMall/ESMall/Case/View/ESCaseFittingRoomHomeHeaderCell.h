
#import <UIKit/UIKit.h>

@class ESFittingRoomBannerModel;
@class SDCycleScrollView;
@protocol ESCaseFittingRoomHomeHeaderCellDelegate <NSObject>

- (NSArray <ESFittingRoomBannerModel *> *)getFittingRoomHeaderDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)loopViewDidCreated:(SDCycleScrollView *)loopView;

@end

@interface ESCaseFittingRoomHomeHeaderCell : UITableViewCell

@property (nonatomic, assign) id<ESCaseFittingRoomHomeHeaderCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
