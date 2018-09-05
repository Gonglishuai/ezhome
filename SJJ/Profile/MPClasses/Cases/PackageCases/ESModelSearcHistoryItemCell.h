
#import <UIKit/UIKit.h>

@protocol ESModelSearcHistoryItemCellDelegate <NSObject>

- (NSString *)getSearchHistoryItemTextWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESModelSearcHistoryItemCell : UITableViewCell

@property (nonatomic, assign) id<ESModelSearcHistoryItemCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
