
#import <UIKit/UIKit.h>

@protocol ESCreateEnterpriseViewDelegate <NSObject>

- (NSInteger)getEnterpriseTableSection;

- (NSInteger)getEnterpriseTableRowsWithSection:(NSInteger)section;

- (CGFloat)getEnterpriseTableRowHeight:(NSIndexPath *)indexPath;

- (NSString *)getItemTypeWithIndexPath:(NSIndexPath *)indexPath;

- (void)completeButtonDidTapped;

@end

@interface ESCreateEnterpriseView : UIView

@property (nonatomic, assign) id<ESCreateEnterpriseViewDelegate>viewDelegate;

- (void)tableViewReload;

@end
