
#import <UIKit/UIKit.h>

@protocol ESHomePageHeadLoopCellDelegate <NSObject>

- (NSArray *)getHeadLoopInformation;

- (void)imageDidTappedWithIndex:(NSInteger)index;

@end

@interface ESHomePageHeadLoopCell : UICollectionViewCell

@property (nonatomic, assign) id<ESHomePageHeadLoopCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

- (void)updateBottomSpaceStatus:(BOOL)showStatus;

- (void)setupTimer;

- (void)invalidateTimer;

@end
