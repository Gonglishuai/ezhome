//
//  CoDesignerDetailScoreCell.h
//  Consumer
//
//  Created by xuezy on 16/7/26.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CoDesignerDetailScoreCellDelegate <NSObject>

/**
 *  @brief the method for get model.
 *
 *  @param nil.
 *
 *  @return designer score.
 */
- (float)getDesignerScore;

@end

@interface CoDesignerDetailScoreCell : UITableViewCell

/// delegate.
@property (nonatomic, assign) id<CoDesignerDetailScoreCellDelegate>delegate;

/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)updateCellForIndex:(NSInteger)index;

@end
