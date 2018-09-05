
#import "ESProductBaseCell.h"

@class ESFlashSaleInfoModel;
@protocol ESProductFlashInfoCellDelegate <ESProductCellDelegate>

- (ESFlashSaleInfoModel *)getProductFlashInfoAtIndexPath:(NSIndexPath *)indexPath;

- (void)countDownTimerDidCreated:(NSTimer *)timer;

- (void)countDownDidOver;

@end

@interface ESProductFlashInfoCell : ESProductBaseCell

@end
