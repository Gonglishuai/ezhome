
#import "ESProductBaseCell.h"

@protocol ESProductDetailCouponsCellDelegate <ESProductCellDelegate>

- (NSArray <NSString *> *)getCouponsWithIndexPath:(NSIndexPath *)indexPath;

- (BOOL)getShowBottomViewStatus;

- (void)moreCouponsDidTapped;

@end

@interface ESProductDetailCouponsCell : ESProductBaseCell

@end
