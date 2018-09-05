
#import "ESPayBaseCell.h"

@protocol ESPayWayCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)paySelectedDidTapped:(NSIndexPath *)indexPath
                       title:(NSString *)title;

@end

@interface ESPayWayCell : ESPayBaseCell

@end
