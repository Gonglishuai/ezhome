
#import <UIKit/UIKit.h>

@protocol ESReturnApplyAmountInputCellDelegate <NSObject>

- (NSString *)getReturnAmountWithIndexPath:(NSIndexPath *)indexPath;

- (void)returnAmountDidEndEditing:(NSString *)amout;

@end

@interface ESReturnApplyAmountInputCell : UITableViewCell

@property (nonatomic, assign) id<ESReturnApplyAmountInputCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
