
#import "ESProductBaseCell.h"

@class ESCartCommodityPromotion;
@protocol ESProductDetailPromotionCellDelegate <ESProductCellDelegate>

- (ESCartCommodityPromotion *)getProductPromotionAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailPromotionCell : ESProductBaseCell

@end
