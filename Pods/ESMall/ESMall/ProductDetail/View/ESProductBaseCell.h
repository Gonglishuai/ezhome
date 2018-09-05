
#import <UIKit/UIKit.h>

@protocol ESProductCellDelegate <NSObject>

@end

@interface ESProductBaseCell : UITableViewCell

@property (nonatomic, assign) id <ESProductCellDelegate> cellDelegate;

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath;

@end
