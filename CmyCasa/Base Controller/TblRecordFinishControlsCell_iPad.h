//
//  TblRecordFinishControlsCell_iPad.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/5/14.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordFinishControlsCell_iPad : TableRecordBaseCell
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelProfileChanges:(id)sender;

- (IBAction)saveProfileChanges:(id)sender;
@end
