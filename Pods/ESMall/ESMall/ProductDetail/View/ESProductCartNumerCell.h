
#import "ESproductCollectionBaseCell.h"

@protocol ESProductCartNumerCellDelegate <ESproductCollectionBaseCellDelegate>

- (BOOL)getCartNumberEnableStatus;
- (NSInteger)getCartNumber;
- (NSInteger)getMaxCartNumber;
- (void)cartNumberButtonDidTappedWithNumber:(NSInteger)number;
- (void)cartShowMessage:(NSString *)message;

@end

@interface ESProductCartNumerCell : ESproductCollectionBaseCell

@end
