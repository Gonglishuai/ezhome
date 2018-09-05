
#import "ESPayBaseCell.h"

@protocol ESPayEnterpriseAgreementCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayEnterpriseDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)agreeButtonDidTapped:(BOOL)selected
                    indexPth:(NSIndexPath *)indexPath;

- (void)agreementButtonDidTapped;

@end

@interface ESPayEnterpriseAgreementCell : ESPayBaseCell

@end
