//
//  CoDesignerCommentCell.h
//  Consumer
//
//  Created by xuezy on 16/7/25.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoDesignerCommentModel.h"
@protocol CoDesignerCommentCellDelegate <NSObject>

/**
 *  @brief the method for get model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPCaseModel model class.
 */
- (CoDesignerCommentModel *)getDesignerCommentModelAtIndex:(NSInteger)index;
@end

@interface CoDesignerCommentCell : UITableViewCell

@property (nonatomic,weak) id<CoDesignerCommentCellDelegate>delegate;
/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)updateCellForIndex:(NSInteger)index;
@end
