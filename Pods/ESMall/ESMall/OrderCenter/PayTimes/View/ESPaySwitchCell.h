
#import "ESPayBaseCell.h"

@protocol ESPaySwitchCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPaySwitchDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)switchValueDidChanged:(BOOL)switchOn
                    indexPath:(NSIndexPath *)indexPath;

@end

@interface ESPaySwitchCell : ESPayBaseCell

@end
