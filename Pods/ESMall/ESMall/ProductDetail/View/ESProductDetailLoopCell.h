
#import "ESProductBaseCell.h"

@class ESProductDetailLoopCell;
@protocol ESProductDetailLoopCellDelegate <ESProductCellDelegate>

- (NSArray *)getLoopImagesAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)getLoopModelUrlAtIndexPath:(NSIndexPath *)indexPath;

- (void)imageDidTppedAtLoopCell:(ESProductDetailLoopCell *)cell
                        index:(NSInteger)index
                     imageViews:(NSArray <UIImageView *> *)imageViews;

@end

@interface ESProductDetailLoopCell : ESProductBaseCell

@end
