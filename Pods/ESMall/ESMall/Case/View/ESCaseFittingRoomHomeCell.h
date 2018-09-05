
#import <UIKit/UIKit.h>

@class ESFittingSampleModel;
@protocol ESCaseFittingRoomHomeCellDelegate <NSObject>

- (ESFittingSampleModel *)getFittingRoomHomeCellDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)categoryImageDidTappedWithIndex:(NSInteger)index;

- (void)categoryMoreDidTappedWithIndex:(NSInteger)index;

- (void)caseImageDidTappedWithIndex:(NSInteger)index
                          caseIndex:(NSInteger)caseIndex;

@end

@interface ESCaseFittingRoomHomeCell : UITableViewCell

@property (nonatomic, assign) id<ESCaseFittingRoomHomeCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
