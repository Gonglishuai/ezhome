/**
 * @file    MPFindDesignersTableViewCell.h
 * @brief   the view for cell.
 * @author  Xue
 * @version 1.0
 * @date    2016-02-17
 */

#import <UIKit/UIKit.h>
@class MPDesignerInfoModel;

@protocol MPFindDesignersTableViewCellDelegate <NSObject>

@required

/**
 *  @brief the method for getting model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPDesignerInfoModel model class.
 */
-(MPDesignerInfoModel *) getDesignerLibraryModelForIndex:(NSUInteger) index;

@end

@interface MPFindDesignersTableViewCell : UITableViewCell

/// delegate.
@property(assign,nonatomic) id<MPFindDesignersTableViewCellDelegate> delegate;

/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
-(void) updateCellForIndex:(NSUInteger) index;
@end
