//
//  TblRecordTextFieldCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordTextFieldCell : TableRecordBaseCell

@property (weak, nonatomic) IBOutlet UITextField *tblRecordText;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *validateButton;
- (IBAction)validateFieldAction:(id)sender;

@end
