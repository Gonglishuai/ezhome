
#import <UIKit/UIKit.h>

@protocol ESproductCollectionBaseCellDelegate <NSObject>

@end

@interface ESproductCollectionBaseCell : UICollectionViewCell

@property (nonatomic, assign) id<ESproductCollectionBaseCellDelegate>cellDelegate;

- (void)updateCellAtIndexPath:(NSIndexPath *)indexPath;

@end
