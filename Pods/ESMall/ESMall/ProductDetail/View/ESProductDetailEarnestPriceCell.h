
#import "ESProductBaseCell.h"

@class ESProductDetailEarnestModel;
@protocol ESProductDetailEarnestPriceCellDelegate <ESProductCellDelegate>

- (ESProductDetailEarnestModel *)getProductEarnestInfoAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailEarnestPriceCell : ESProductBaseCell

@end
