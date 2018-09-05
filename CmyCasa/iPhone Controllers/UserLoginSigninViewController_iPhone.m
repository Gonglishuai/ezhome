//
//  UserLoginSigninViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "UserLoginSigninViewController_iPhone.h"
#import "HCGooglePlusManager.h"

#define TEXT_EDIT_TAG_USER 1000
#define TEXT_EDIT_TAG_PASS 1005


@interface UserLoginSigninViewController_iPhone ()
{
    BOOL _animationDone;
}
@end

@implementation UserLoginSigninViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)facebookPressed:(id)sender{
    [HSFlurry logAnalyticEvent:EVENT_NAME_FACEBOOK_SIGNUP withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
                                                                               self.eventLoadOrigin}];
    [self.facebookIndicator startAnimating];
    [[HCFacebookManager sharedInstance] facebookLogin:^(BOOL state){
        if(state == NO)
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:NSLocalizedString(@"facebook_login_general_error",  "Sign in failed, please check your Facebook account details and try again.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"OK") otherButtonTitles: nil];
            [alert show];
        }
        [self.facebookIndicator stopAnimating];
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)googlePlusPressed:(id)sender
{
    [HSFlurry logAnalyticEvent:EVENT_NAME_GOOGLE_SIGNUP withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:self.eventLoadOrigin}];

    if ([ConfigManager showMessageIfDisconnected]) {
        return;
    }
    
    [self.googleIndicator startAnimating];
    [[HCGooglePlusManager sharedInstance] doSignIn:^(BOOL state){
        if(state == NO)
        {
            UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:NSLocalizedString(@"googleplus_login_general_error",  "Sign in failed, please check your Google+ account details and try again.") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"OK") otherButtonTitles: nil];
            [alert show];
        }
        [self.googleIndicator stopAnimating];
        [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _animationDone = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)navBack:(id)sender {
    [super backToSignUpPressed:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == TEXT_EDIT_TAG_USER && !_animationDone) {
        _animationDone = YES;
        __block CGRect frm = self.view.frame;
        frm.origin.y = -150;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.view.frame = frm;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    if (textField.tag == TEXT_EDIT_TAG_PASS) {
        [self closeAnimation];
    }
}

- (IBAction)signInPressed:(id)sender{
    [self closeAnimation];
    [super signInPressed:sender];
}

-(void)closeAnimation{
    __block CGRect frm = self.view.frame;
    frm.origin.y = 0;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.view.frame = frm;
    } completion:^(BOOL finished) {}];
}

@end
