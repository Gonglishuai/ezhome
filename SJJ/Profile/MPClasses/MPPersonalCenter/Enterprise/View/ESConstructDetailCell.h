
#import <UIKit/UIKit.h>

@protocol ESConstructDetailCellDelegate <NSObject>

- (NSDictionary *)getDetailDataWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESConstructDetailCell : UITableViewCell

@property (nonatomic, assign) id<ESConstructDetailCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
