//
//  MPHome3DViewCell.h
//  Consumer
//
//  Created by 董鑫 on 16/8/22.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESDesignCaseList.h"

@protocol MPHome3DViewCellDelegate <NSObject>
/**
 *  @brief the method for getting model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPCaseModel model class.
 */
- (ESDesignCaseList *)get3DDatamodelForIndex:(NSUInteger)index;

/**
 *  @brief the method for click designer icon.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)designer3DIconClickedAtIndex:(NSUInteger)index;

@end

@interface MPHome3DViewCell : UICollectionViewCell
/// delegate.
@property (nonatomic, weak) id<MPHome3DViewCellDelegate> delegate;
/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void) update3DCellUIForIndex:(NSUInteger)index;

@end
