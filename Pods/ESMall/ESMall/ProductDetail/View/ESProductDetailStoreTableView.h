
#import <UIKit/UIKit.h>

@protocol ESProductDetailStoreTableViewDelegate <NSObject>

@end

@interface ESProductDetailStoreTableView : UIView

@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, assign) id<ESProductDetailStoreTableViewDelegate>viewDelegate;

@end
