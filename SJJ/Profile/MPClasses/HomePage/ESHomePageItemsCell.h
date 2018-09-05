
#import <UIKit/UIKit.h>

@protocol ESHomePageHeadItemCellDelegate <NSObject>

- (NSArray *)getHeadItemsInformation;

- (void)itemDidTappedWithType:(NSInteger)index;

@end



@interface ESHomePageItemsCell : UICollectionViewCell

@property (nonatomic, assign) id<ESHomePageHeadItemCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
