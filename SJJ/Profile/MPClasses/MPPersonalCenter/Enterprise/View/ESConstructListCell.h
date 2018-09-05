
#import <UIKit/UIKit.h>

@class ESConstructModel;
@protocol ESConstructListCellDelegate <NSObject>

- (ESConstructModel *)getConstructDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)constructDetailDidTapped:(NSIndexPath *)indexPath;

@end

@interface ESConstructListCell : UITableViewCell

@property (nonatomic, assign) id<ESConstructListCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
