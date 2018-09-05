
#import <UIKit/UIKit.h>

@protocol ESSaleAgreementCellDelegate <NSObject>

@optional
- (BOOL)getSaleAgreementStatus:(NSIndexPath *)indexPath;

@end

@interface ESSaleAgreementCell : UITableViewCell

@property (nonatomic, assign) id<ESSaleAgreementCellDelegate>cellDelegate;

- (void)updateSaleAgreementCellWithIndex:(NSIndexPath *)indexPath;

@end
