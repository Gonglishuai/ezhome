//
//  TblRecordWebLinkCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/2/14.
//
//

#import "TableRecordBaseCell.h"

@interface TblRecordWebLinkCell : TableRecordBaseCell<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *tblWebLinkButton;

@property(nonatomic,strong)NSString * webURL;
- (IBAction)webLinkActivation:(id)sender;

@end
