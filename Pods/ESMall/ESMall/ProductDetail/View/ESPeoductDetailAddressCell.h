
#import "ESProductBaseCell.h"

@class ESProductStoreModel;
@protocol ESPeoductDetailAddressCellDelegate <ESProductCellDelegate>

- (ESProductStoreModel *)getProductAddressAtIndexPath:(NSIndexPath *)indexPath;

- (void)productDetailMapButtonDidTapped;

@end

@interface ESPeoductDetailAddressCell : ESProductBaseCell

@end
