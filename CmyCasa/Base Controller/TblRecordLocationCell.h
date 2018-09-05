//
//  TblRecordLocationCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/6/14.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordLocationCell : TableRecordBaseCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *getUpdateLocationButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *removeLocationButton;
- (IBAction)removeLocationAction:(id)sender;
- (IBAction)getUpdateLocationAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *tblLocationField;
@end
