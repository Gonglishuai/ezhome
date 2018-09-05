
#import <UIKit/UIKit.h>

@protocol MPDesignerDetailViewDelegate <NSObject>


/**
 *  @brief the method for get cell type.
 *
 *  @param nil.
 *
 *  @return NSInteger cell type.
 */
- (NSInteger)getDesignerCellType;

/**
 *  @brief the method for get comments count.
 *
 *  @param nil.
 *
 *  @return NSInteger comments count.
 */
- (NSInteger)getDesignerDetailCommentsCount;

/**
 *  @brief the method for click cell.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)didSelectCellAtIndex:(NSInteger)index withInSection:(NSInteger)section;

/**
 *  @brief the method for get case count.
 *
 *  @param nil.
 *
 *  @return NSInteger case count.
 */
- (NSInteger)getDesignerDetailCaseCount;

/**
 *  @brief the method for get 3D case count.
 *
 *  @param nil.
 *
 *  @return NSInteger 3D case count.
 */
- (NSInteger)getDesignerDetail3DCaseCount;


/**
 *  @brief the method for load new data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)designerDetailViewRefreshLoadNewData:(void(^) (void))finish;

/**
 *  @brief the method for load more data.
 *
 *  @param finish the block for load over.
 *
 *  @return void nil.
 */
- (void)designerDetailViewRefreshLoadMoreData:(void(^) (void))finish;

@end

@interface MPDesignerDetailView : UIView

/// delegate.
@property (nonatomic, assign) id<MPDesignerDetailViewDelegate>delegate;

/// is designer or not.
@property (nonatomic, assign) BOOL isDesigner;
@property (nonatomic, strong) UITableView *deisgnerTableView;    //!< _tableView the tableView.

/// is designer cell type.
@property (nonatomic, assign) NSInteger designerType;
/**
 *  @brief the method for refresh View.
 *
 *  @param nil.
 *
 *  @return void nil.
 */
- (void)refreshDesignerDetailUI;

@end
