//
//  ProfileBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import <UIKit/UIKit.h>

#import "LoginDefs.h"

@class MessageUI;
@class MFMailComposeViewController;

@interface ProfileBaseViewController : UIViewController<UserLogInDelegate, UIImagePickerControllerDelegate,
UIPopoverControllerDelegate,UITextFieldDelegate,MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>



- (IBAction)closeProfileUI:(id)sender;
- (IBAction)changeProfileImage:(id)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)signoutUser:(id)sender;
- (IBAction)tellUsHow:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate:
(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate forView:(UIView*)mview;
@property (weak, nonatomic) IBOutlet UITextField *userLastName;

@property (weak, nonatomic) IBOutlet UITextField *userFirstName;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButtn;
@property (weak, nonatomic) IBOutlet UIButton *changeImageButton;
@property (weak, nonatomic) IBOutlet UIButton *doneAction;

@property(nonatomic) NSCharacterSet *blockedCharacters;
@property(nonatomic) BOOL imageChanged;



-(void)loadProfileImage:(NSString*)profileImage;

- (void)actionEmailComposer ;


@end
