
#import <UIKit/UIKit.h>

@class ESProductDetailCouponsModel;
@protocol ESProductCouponListCellDelegate <NSObject>

- (ESProductDetailCouponsModel *)getCouponListDataWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductCouponListCell : UITableViewCell

@property (nonatomic, assign) id<ESProductCouponListCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
