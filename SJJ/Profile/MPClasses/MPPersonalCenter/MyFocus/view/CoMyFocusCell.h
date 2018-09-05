/**
 * @file    CoMyFocusCell.h
 * @brief   the view for cell.
 * @author  Xue
 * @version 1.0
 * @date    2016-07-18
 */

#import <UIKit/UIKit.h>
#import "ESCommentFocusModel.h"

@protocol CoMyFocusCellDelegate <NSObject>

@required

/**
 *  @brief the method for getting model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return CoMyFocusModel model class.
 */
-(ESCommentFocusModel *) getFocusDesignersModelForIndex:(NSUInteger) index;

/**
 *  @brief the method for detail view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
-(void) clickUnsubscribeDesignerForIndex:(NSUInteger) index;



@end


@interface CoMyFocusCell : UITableViewCell


/// designer name.
@property (nonatomic,strong)IBOutlet UILabel *nameLabel;


/// designer head image.
@property (nonatomic,strong)IBOutlet UIImageView *memberAvatar;

/// designer head image.
@property (nonatomic,strong)IBOutlet UIImageView *idImageView;

/// delegate.
@property(assign,nonatomic) id<CoMyFocusCellDelegate> delegate;
- (IBAction)cancleBtn:(id)sender;

/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
-(void) updateCellForIndex:(NSUInteger) index;
@end
