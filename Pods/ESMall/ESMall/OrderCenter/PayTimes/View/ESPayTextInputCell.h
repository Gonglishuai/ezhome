
#import "ESPayBaseCell.h"

@protocol ESPayTextInputCellDelegate <ESPayBaseCellDelegate>

- (NSDictionary *)getPayTextInputDataWithIndexPath:(NSIndexPath *)indexPath;

- (void)payAmountTextFieldDidEndEditing:(NSString *)text
                              indexPath:(NSIndexPath *)indexPath;

- (BOOL)                textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string;

@end

@interface ESPayTextInputCell : ESPayBaseCell

@end
