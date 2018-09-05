
#import "ESProductBaseCell.h"

@class ESProductBrandModel;
@protocol ESProductDetailBrandCellDelegate <ESProductCellDelegate>

- (ESProductBrandModel *)getBrandInformationAtIndexPath:(NSIndexPath *)indexPath;

- (void)chatButtonDidTapped;

@end

@interface ESProductDetailBrandCell : ESProductBaseCell

@end
