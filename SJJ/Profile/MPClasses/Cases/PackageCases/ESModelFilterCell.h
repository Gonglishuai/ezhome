
#import <UIKit/UIKit.h>

@class ESSampleRoomTagFilterModel;
@protocol ESModelFilterCellDelegate <NSObject>

- (ESSampleRoomTagFilterModel *)getFilterDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)itemDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESModelFilterCell : UICollectionViewCell

@property (nonatomic, assign) id<ESModelFilterCellDelegate>cellDelegate;

- (void)updateFilterCellWithIndexPath:(NSIndexPath *)indexPath;

@end
