
#import <UIKit/UIKit.h>

@class MPCaseModel;
@class ESDesignCaseList;
@protocol MPDesignerDetailTableViewCellDelegate <NSObject>

/**
 *  @brief the method for get model.
 *
 *  @param index the index for model in datasource.
 *
 *  @return MPCaseModel model class.
 */
- (ESDesignCaseList *)getDesignerDetailModelAtIndex:(NSInteger)index;

@end

@interface MPDesignerDetailTableViewCell : UITableViewCell

/// delegate.
@property (nonatomic, assign) id<MPDesignerDetailTableViewCellDelegate>delegate;

/**
 *  @brief the method for updating view.
 *
 *  @param index the index for model in datasource.
 *
 *  @return void nil.
 */
- (void)updateCellForIndex:(NSInteger)index;

- (void)setModel:(ESDesignCaseList *)model;
@end
