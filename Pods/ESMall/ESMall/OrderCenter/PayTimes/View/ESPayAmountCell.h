
#import "ESPayBaseCell.h"

@protocol ESPayAmountCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayAmountDataWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESPayAmountCell : ESPayBaseCell

@end
