//
//  ProfileUserDetailsViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 1/6/14.
//
//333

#import "ProfileUserDetailsBaseViewController.h"

@interface ProfileUserDetailsViewController_iPhone : ProfileUserDetailsBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *genericCloseButton;

- (IBAction)topRightAction:(id)sender;
- (IBAction)navigateBack:(id)sender;

@end
