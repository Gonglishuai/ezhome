
#import "ESProductBaseCell.h"

@protocol ESProductDetailPromiseCellDelegate <ESProductCellDelegate>

- (void)productDetailPromiseDetailButtonDidTapped;

- (NSArray <NSDictionary *> *)getProductPromisesAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailPromiseCell : ESProductBaseCell

@end
