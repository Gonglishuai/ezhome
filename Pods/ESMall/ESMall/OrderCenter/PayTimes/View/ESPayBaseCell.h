
#import <UIKit/UIKit.h>

@protocol ESPayBaseCellDelegate <NSObject>

@end

@interface ESPayBaseCell : UITableViewCell

@property (nonatomic, assign) id<ESPayBaseCellDelegate>cellDelegate;

@property (nonatomic, weak) UITableView *tableView;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
