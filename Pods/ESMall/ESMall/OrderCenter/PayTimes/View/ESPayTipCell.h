
#import "ESPayBaseCell.h"

@protocol ESPayTipCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayTipMessageWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESPayTipCell : ESPayBaseCell

@end
