
#import "ESProductBaseCell.h"

@class ESProductModel;
@protocol ESProductInformationCellDelegate <ESProductCellDelegate>

- (ESProductModel *)getProductInfomationAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductInformationCell : ESProductBaseCell

@end
