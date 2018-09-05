
#import "ESProductBaseCell.h"

@class ESProductAttributeSelectedValueModel;
@protocol ESProductDetailParametersCellDelegate <ESProductCellDelegate>

- (ESProductAttributeSelectedValueModel *)getProductDetailParametersAtIndex:(NSInteger)index;

- (BOOL)getParametersBottomConstraintShowStatusWithIndex:(NSInteger)index;

@end

@interface ESProductDetailParametersCell : ESProductBaseCell

@end
