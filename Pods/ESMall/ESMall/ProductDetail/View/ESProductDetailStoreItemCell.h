
#import "ESProductBaseCell.h"

@class ESProductStoreModel;
@protocol ESProductDetailStoreItemCellDelegate <ESProductCellDelegate>

- (ESProductStoreModel *)getProductStoreInformationAtIndexPath:(NSIndexPath *)indexPath;

- (void)productStoreNavigationButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath;

- (void)productStoreCallButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESProductDetailStoreItemCell : ESProductBaseCell

@end
