//
//  TblRecordProfileImageCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/18/13.
//
//

#import <UIKit/UIKit.h>
#import "TableRecordBaseCell.h"
@interface TblRecordProfileImageCell : TableRecordBaseCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIButton *changePassButton;
@property (weak, nonatomic) UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButtonIcon;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;
@property (weak, nonatomic) IBOutlet UIView *cameraButtonBgView;

- (IBAction)changeProfileImageAction:(id)sender;
- (IBAction)changePasswordAction:(id)sender;
@end
