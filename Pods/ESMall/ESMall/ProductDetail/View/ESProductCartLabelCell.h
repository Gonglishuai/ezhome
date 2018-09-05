
#import "ESproductCollectionBaseCell.h"

@class ESProductAttributeValueModel;
@protocol ESProductCartLabelCellDelegate <ESproductCollectionBaseCellDelegate>

- (ESProductAttributeValueModel *)getCartItemMessageAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductCartLabelCell : ESproductCollectionBaseCell

@end
