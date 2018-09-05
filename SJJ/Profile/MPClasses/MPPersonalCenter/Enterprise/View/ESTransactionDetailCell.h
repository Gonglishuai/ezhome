
#import <UIKit/UIKit.h>

@class ESTransactionDetailModel;
@protocol ESTransactionDetailCellDelegate <NSObject>

- (ESTransactionDetailModel *)getDetailDataWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESTransactionDetailCell : UITableViewCell

@property (nonatomic, assign) id<ESTransactionDetailCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
