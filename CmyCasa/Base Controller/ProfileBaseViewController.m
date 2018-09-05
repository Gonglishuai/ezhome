//
//  ProfileBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "ProfileBaseViewController.h"
#import "UserManager.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "HelpersRO.h"
#import "UIImagePickerController+hideStatusBar.h"
#import "NotificationNames.h"

@interface ProfileBaseViewController ()

@end

@implementation ProfileBaseViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)closeProfileUI:(id)sender{
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller usingDelegate:
(id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate forView:(UIView*)mview{
    return NO;
}

#pragma mark -
#pragma mark UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CGRect frm=self.view.frame;
    
    frm.origin.y=-88;
    self.view.frame=frm;
}

// became first responder
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    if (textField==self.userLastName && [self.userFirstName isFirstResponder]) {
        
        return;
    }
    
    if (textField==self.userFirstName && [self.userLastName isFirstResponder]) {
        return ;
    }
    
    CGRect frm=self.view.frame;
    
    frm.origin.y=0;
    self.view.frame=frm;
}

- (void)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        
        
        [mailViewController setSubject: NSLocalizedString(@"feedback_email_subject",@"Share with Homestyler Team")];
        
        [mailViewController setMessageBody:NSLocalizedString(@"feedback_email_body",@"") isHTML:NO];
        
        // Attach an image to the email.
        
        NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
        if(dict!=NULL){
            
            [mailViewController setToRecipients:[NSArray arrayWithObject:[[dict objectForKey:@"feedback"] objectForKey:@"toaddress"]]];
            
        }
        // Present the view controller
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self  presentViewController:mailViewController animated:YES completion:nil];
        });
    }
    
    else {
        
        HSMDebugLog(@"Device is unable to send email in its current state.");
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    if(result	!=	MFMailComposeResultCancelled)
    {
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return ([string rangeOfCharacterFromSet:self.blockedCharacters].location == NSNotFound);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return ([text rangeOfCharacterFromSet:self.blockedCharacters].location == NSNotFound);
}

-(void)loadProfileImage:(NSString*)profileImage{
    
    if (!profileImage || [profileImage length]==0) {
        [self.profileImage setImage:[UIImage imageNamed:@"profile_page_image.png"]];
        return;
    }

    [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.profileImage url:profileImage];
}

- (IBAction)changeProfileImage:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self forView:self.view ];
}

- (IBAction)changePassword:(id)sender {
    [[UIMenuManager sharedInstance] resetPasswordPressed:self.parentViewController];
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    
}

- (IBAction)signoutUser:(id)sender {
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        return;
    }else{
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent: FLURRY_SIGNOUT];
        }
#endif
        
        self.userFirstName.text=@"";
        self.userLastName.text=@"";
        self.profileImage.image=nil;
        
        [[AppCore sharedInstance] logoutUser];
        
        [self closeProfileUI:nil];
    }
}

- (IBAction)tellUsHow:(id)sender {
    [self actionEmailComposer];
}

@end
