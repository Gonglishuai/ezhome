//
//  TblRecordToggleCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/31/13.
//
//

#import "TableRecordBaseCell.h"

@class UserComboDO;

@interface TblRecordToggleCell : TableRecordBaseCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *tblSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *removeGenderButton;
@property (nonatomic, strong) UserComboDO * genderOption;
- (IBAction)segmentSelectionChange:(id)sender;
- (IBAction)removeGenderData:(id)sender;
@end
