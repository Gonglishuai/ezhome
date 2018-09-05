//
//  CoMyFocusView.h
//  Consumer
//
//  Created by Jiao on 16/7/18.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CoMyFocusViewDelegate <NSObject>

@optional

/**
 *  @brief the method for click cell.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)didSelectItemAtIndex:(NSInteger)index;

/**
 *  @brief the method for get designers count.
 *
 *  @param nil.
 *
 *  @return NSInteger designers count.
 */
- (NSInteger)getFocusDesignersCount;


/**
 *  @brief the method for load new data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)focusDesignersViewRefreshLoadNewData:(void(^) (void))finish;

/**
 *  @brief the method for load more data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)focusDesignersViewRefreshLoadMoreData:(void(^) (void))finish;

@end

@interface CoMyFocusView : UIView
/// delegate.
@property (weak, nonatomic)id<CoMyFocusViewDelegate>delegate;

@property (nonatomic,strong) UITableView *focusDesignersTabelView;    //!< the tableview of listView.
/**
 *  @brief the method for refresh View.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void) refreshFocusDesignersUI;


@end
