
#import "ESProductBaseCell.h"

@class ESProductDetailSampleroomModel;
@protocol ESProductDetailModelCellDelegate <ESProductCellDelegate>

- (NSInteger)getProductSampleroomCountAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailModelCell : ESProductBaseCell

@end
