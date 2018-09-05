
#import <UIKit/UIKit.h>
#import "ESDesignCaseList.h"

@protocol MPHomeViewCellDelegate <NSObject>
/**
 *  @brief the method for getting model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPCaseModel model class.
 */
- (ESDesignCaseList *)getDatamodelForIndex:(NSUInteger)index;

/**
 *  @brief the method for click designer icon.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)designerIconClickedAtIndex:(NSUInteger)index;

@end





@interface MPHomeViewCell : UICollectionViewCell

/// delegate.
@property (nonatomic, weak) id<MPHomeViewCellDelegate> delegate;

/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void) updateCellUIForIndex:(NSUInteger)index;

@end
