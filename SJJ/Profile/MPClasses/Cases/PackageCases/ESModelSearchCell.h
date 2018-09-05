
#import <UIKit/UIKit.h>

@protocol ESModelSearchCellDelegate <NSObject>

- (NSString *)getSearchTipTextWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESModelSearchCell : UITableViewCell

@property (nonatomic, assign) id<ESModelSearchCellDelegate>cellDelegate;

- (void)updateSearchCellWithIndexPath:(NSIndexPath *)indexPath;

@end
