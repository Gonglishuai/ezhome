
#import <UIKit/UIKit.h>

@protocol ESHomePageHeadLineCellDelegate <NSObject>

- (NSArray *)getHeadLineInformation;

- (void)headLineDidTappedWithIndex:(NSInteger)index;

@end

@interface ESHomePageHeadLineCell : UICollectionViewCell

@property (nonatomic, assign) id<ESHomePageHeadLineCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

- (void)setupTimer;

- (void)invalidateTimer;

@end
