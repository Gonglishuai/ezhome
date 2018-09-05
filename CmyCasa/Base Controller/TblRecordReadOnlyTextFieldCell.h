//
//  TblRecordTextFieldCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordReadOnlyTextFieldCell : TableRecordBaseCell

@property (weak, nonatomic) IBOutlet UILabel *tblRecordText;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
- (IBAction)actionClick:(id)sender;

@end
