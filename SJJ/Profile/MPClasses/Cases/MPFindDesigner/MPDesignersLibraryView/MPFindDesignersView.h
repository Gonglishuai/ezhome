/**
 * @file    MPFindDesignersView.h
 * @brief   the view of find designer.
 * @author  Xue
 * @version 1.0
 * @date    2016-02-17
 */

#import <UIKit/UIKit.h>
@protocol MPFindDesignersViewDelegate <NSObject>

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
 *  @brief the method for get designers count.
 *
 *  @param nil.
 *
 *  @return NSInteger designers count.
 */
- (NSInteger)getDesignerCellCount;

/**
 *  @brief the method for load new data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)findDesignersViewRefreshLoadNewData:(void(^) (void))finish;

/**
 *  @brief the method for load more data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)findDesignersViewRefreshLoadMoreData:(void(^) (void))finish;

@end

@interface MPFindDesignersView : UIView<UITableViewDataSource,UITableViewDelegate>

/// delegate.
@property (weak, nonatomic)id<MPFindDesignersViewDelegate>delegate;

/**
 *  @brief the method for refresh View.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void) refreshFindDesignersUI;

- (void)startMJRefreshHeader;
@end
