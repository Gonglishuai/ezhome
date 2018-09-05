
#import "ESCreateEnterpriseBaseCell.h"

@protocol ESCreateTextFieldCellDelegate <ESCreateEnterpriseBaseCellDelegate>

- (NSDictionary *)getTextFieldCellDisplayInformationWithIndexPath:(NSIndexPath *)indexPath;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
                          indexPath:(NSIndexPath *)indexPath;
- (void)textFieldDidBeginEditing:(UITextField *)textField
                       indexPath:(NSIndexPath *)indexPath;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
                        indexPath:(NSIndexPath *)indexPath;
- (void)textFieldDidEndEditing:(UITextField *)textField
                     indexPath:(NSIndexPath *)indexPath;
- (void)textFieldDidEndEditing:(UITextField *)textField
                        reason:(UITextFieldDidEndEditingReason)reason
                     indexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(10_0);

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
                        indexPath:(NSIndexPath *)indexPath;

- (BOOL)textFieldShouldClear:(UITextField *)textField
                   indexPath:(NSIndexPath *)indexPath;
- (BOOL)textFieldShouldReturn:(UITextField *)textField
                    indexPath:(NSIndexPath *)indexPath;

@end

@interface ESCreateTextFieldCell : ESCreateEnterpriseBaseCell

- (void)updateCellWithIndexPath:(NSIndexPath *)indexPath;

@end
