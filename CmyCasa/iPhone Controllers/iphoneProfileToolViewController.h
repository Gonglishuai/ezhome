//
//  iphoneProfileToolViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/5/13.
//
//

#import "ProfileToolBaseViewController.h"

@interface iphoneProfileToolViewController : ProfileToolBaseViewController

- (IBAction)navigateBack:(id)sender;

- (IBAction)signoutUser:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UITextField *userLastName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *userFirstName;
-(void)loadProfileImage:(NSString*)profileImage;
@end
