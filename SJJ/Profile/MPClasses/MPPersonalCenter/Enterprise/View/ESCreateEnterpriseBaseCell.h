
#import <UIKit/UIKit.h>

@protocol ESCreateEnterpriseBaseCellDelegate <NSObject>

@end

@interface ESCreateEnterpriseBaseCell : UITableViewCell

@property (nonatomic, assign) id<ESCreateEnterpriseBaseCellDelegate>cellDelegate;

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
