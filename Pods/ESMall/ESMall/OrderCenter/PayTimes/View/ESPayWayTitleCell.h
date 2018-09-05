
#import "ESPayBaseCell.h"

@protocol ESPayWayTitleCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayWayTitleWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESPayWayTitleCell : ESPayBaseCell

@end
