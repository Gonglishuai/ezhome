
#import "ESCreateEnterpriseBaseCell.h"

@protocol ESCreateButtonCellDelegate <ESCreateEnterpriseBaseCellDelegate>

- (NSDictionary *)getButtonCellDisplayMessageWith:(NSIndexPath *)indexPath;

- (void)messageButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface ESCreateButtonCell : ESCreateEnterpriseBaseCell

@end
