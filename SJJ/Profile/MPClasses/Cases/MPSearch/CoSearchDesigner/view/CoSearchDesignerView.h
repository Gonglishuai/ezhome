//
//  CoSearchDesignerView.h
//  Consumer
//
//  Created by xuezy on 16/8/11.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CoSearchDesignerViewDelegate <NSObject>

@required

/**
 *  @brief the method for click cell.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)didSelectItemAtIndex:(NSInteger)index;

/**
 *  @brief the method for get needs count.
 *
 *  @param nil.
 *
 *  @return NSInteger needs count.
 */
- (NSInteger)getDesignerCellCount;

/**
 *  @brief the method for load new data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)searchDesignerViewRefreshLoadNewData:(void(^) (void))finish;

/**
 *  @brief the method for load more data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)searchDesignerViewRefreshLoadMoreData:(void(^) (void))finish;

/**
 *  @brief the method for search keywords.
 *
 *  @param searchKey the textField of connect.
 *
 *  @return void nil.
 */
-(void)onSearchTrigerred:(NSString*) searchKey;

/**
 *  @brief the method for close search view.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
-(void)onSearchViewDismiss;

/**
 *  @brief the method for search keywords.
 *
 *  @param typeString the select value.
 *  @param titleString the select type title.
 *  @return void nil.
 */
- (void)stringSelectType:(NSString *)typeString withTitleString:(NSString *)titleString;
@end

@interface CoSearchDesignerView : UIView

/// delegate.
@property (weak, nonatomic) id<CoSearchDesignerViewDelegate> delegate;

/**
 *  @brief the method for refresh View.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void) refreshSearchDesignerViewUI;

/**
 *  @brief the method for remove keyboard.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void)removeKeyBoardObserver;

@end
