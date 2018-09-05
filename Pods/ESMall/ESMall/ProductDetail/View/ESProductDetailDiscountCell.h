
#import "ESProductBaseCell.h"

@protocol ESProductDetailDiscountCellDelegate <ESProductCellDelegate>

- (NSArray *)getProductDiscountAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailDiscountCell : ESProductBaseCell

@end
