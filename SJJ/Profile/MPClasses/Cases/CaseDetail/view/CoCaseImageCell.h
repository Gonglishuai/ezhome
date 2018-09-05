//
//  CoCaseImageCell.h
//  Consumer
//
//  Created by Jiao on 16/7/20.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoCaseImageCell;
@protocol CoCaseImageCellDelegate <NSObject>

/**
 *  @brief the method for getting model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPCaseImageModel model class.
 */
-(NSString *) getCaseLibraryDetailModelForSection:(NSInteger)section withIndex:(NSUInteger) index;

/**
 *  @brief the method for show view.
 *
 *  @param nil.
 *
 *  @return show view.
 */
- (UIView *)getControllerView;

- (NSArray *)getCaseArr;

- (void)caseImageCellDidSelectedPhoto:(CoCaseImageCell *)cell
                            imageView:(UIImageView *)imageView
                           photoIndex:(NSInteger)photoIndex;

@end
@interface CoCaseImageCell : UITableViewCell
@property (nonatomic, weak) id<CoCaseImageCellDelegate> delegate;
- (void) updateCellForSection:(NSInteger)section withIndex:(NSUInteger)index;
//-(void)getImageShowforScroller:(NSArray*)imageShowScoller;

@end
