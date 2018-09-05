//
//  UserLoginOptionsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "UserLoginOptionsViewController_iPhone.h"
#import "RegistrationViewController_iPhone.h"
#import "ControllersFactory.h"

@interface UserLoginOptionsViewController_iPhone ()

@property (weak, nonatomic) UILabel *lblSignInWith;
@property (weak, nonatomic) UILabel *lblAlreadyHaveAccount;
@property (weak, nonatomic) UIButton *btnLogin;

@end

@implementation UserLoginOptionsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    _signinLbl.text = NSLocalizedString(@"signin_title", @"");
    self.lblAlreadyHaveAccount.text = @"already_have_account";
    self.lblSignInWith.text = @"sign_in_with";
    [self.btnLogin setTitle:@"login" forState:UIControlStateNormal];
    [self initTextOfStatement:self.userTip];
    [self initTextOfStatement:self.lblPrivacyStatementAndTerms];
}

-(IBAction)facebookPressed:(id)sender{
    [super facebookPressed:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"userSignInSegue"])
	{
        [super facebookPressed:nil];
	}
    
    if ([segue.identifier isEqualToString:@"UserSignupSegue"])
	{
        [super signupPressed:nil];
	}
}

- (IBAction)signupPressed:(id)sender{
    [super signupPressed:sender];
        
    RegistrationViewController_iPhone * isv = [ControllersFactory instantiateViewControllerWithIdentifier:@"RegistrationMailViewController_iPad" inStoryboard:kLoginStoryboard];
    isv.eventLoadOrigin=self.eventLoadOrigin;
    isv.delegate=self.delegate;
    
    [self.navigationController pushViewController:isv animated:YES];
}

- (IBAction)navBack:(id)sender {
    
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(navBackPressed)]) {
        [self.delegate performSelector:@selector(navBackPressed)];
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
