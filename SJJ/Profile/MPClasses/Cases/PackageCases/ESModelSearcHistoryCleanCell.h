
#import <UIKit/UIKit.h>

@protocol ESModelSearcHistoryCleanCellDelegate <NSObject>

- (NSString *)getSearchHistoryTipTextWithIndexPath:(NSIndexPath *)indexPath;

- (void)cleanButtonDidTapped;

@end

@interface ESModelSearcHistoryCleanCell : UITableViewCell

@property (nonatomic, assign) id<ESModelSearcHistoryCleanCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
