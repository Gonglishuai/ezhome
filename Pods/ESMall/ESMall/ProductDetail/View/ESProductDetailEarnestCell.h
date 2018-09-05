#import "ESProductBaseCell.h"

@class ESProductDetailEarnestModel;
@protocol ESProductDetailEarnestCellDelegate <ESProductCellDelegate>

- (ESProductDetailEarnestModel *)getProductEarnestInfoAtIndexPath:(NSIndexPath *)indexPath;

- (void)earnestCountDownTimerDidCreated:(NSTimer *)timer;

- (void)earnestCountDownDidOver;

@end

@interface ESProductDetailEarnestCell : ESProductBaseCell

@end
