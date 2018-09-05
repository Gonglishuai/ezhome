//
//  UserLoginViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import "UserLoginViewController.h"
#import "UIViewController+Helpers.h"
#import "FindFriendsBaseViewController.h"
#import "ControllersFactory.h"

@interface UserLoginViewController (){
    
    UINavigationController * _nav;
}

@end

@implementation UserLoginViewController

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([ConfigManager isFaceBookLoginActive]) {
        _isFaceBookActive = YES;
    }
    
    if ([ConfigManager isEmailLoginActive]) {
        _isEmailActive = YES;
    }
    
    if (!_nav)
    {
        // TODO (TOMER) : Refactor this part. The container VC just hold a navigation controller to allow easy transitioning
        UIViewController * containerVc = [[UIViewController alloc] init];
        [containerVc.view setFrame:self.view.bounds];
        
        //Special Case
        if (!_isFaceBookActive)
        {
            _rmvc = [ControllersFactory instantiateViewControllerWithIdentifier:@"RegistrationMailViewController_iPad" inStoryboard:kLoginStoryboard];
            _rmvc.isOnlyEmailActive = YES;
            [containerVc addChildViewController:_rmvc];
            [containerVc.view addSubview:_rmvc.view];
            _rmvc.delegate = self;
            _rmvc.eventLoadOrigin = self.eventLoadOrigin;
        }
        else
        {
            _signUpViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginOptionsController" inStoryboard:kLoginStoryboard];
            [containerVc addChildViewController:_signUpViewController];
            [containerVc.view addSubview:_signUpViewController.view];
            _signUpViewController.delegate = self;
        }
        
        _nav = [[UINavigationController alloc] initWithRootViewController:containerVc];
        [_nav.view setFrame:self.view.bounds];
        [_nav setNavigationBarHidden:YES];
        [self.view addSubview:_nav.view];
         [self addChildViewController:_nav];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc - UserLoginViewController");
}

-(void)facebookLoginFailed:(NSNotification *)notification{
    NSString * res = [notification object];
    NSString * err = [[HSErrorsManager sharedInstance] getErrorByGuidLocalized:res];
    
    if (err) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                         message:err
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                                               otherButtonTitles: nil];
        
        [alert show];
    }
    
    [self.userLogInDelegate loginRequestEndedwithState:NO];
}

-(void)facebookLoginDone:(NSNotification*)notification{
    if ([notification object]!=nil) {
                
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"signup_ok",@""), [ConfigManager getAppName]]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"alert_action_ok",@"")
                                              otherButtonTitles:nil];
        [alert show];
        [self dismissUserLoginViewController];
    }
    else
    {
        [self.userLogInDelegate loginRequestEndedwithState:YES];
        [self closeSignInView];
    }
}

-(void)AcceptTermsFinishedNotification{
    self.termsUIIsopen=NO;
    [self.userLogInDelegate loginRequestEndedwithState:YES];
    [self signedUpSuccessfully];
}

-(void)termsDeclined:(NSNotification*)notification{
    
     self.termsUIIsopen = NO;
    
    if ([notification object]!=nil && [(NSString*)[notification object]isEqualToString:@"facebook"]) {
        //open login facebook/email
        [self.userLogInDelegate loginRequestEndedwithState:NO];

        [self closeSignInView];
        
        [[AppCore sharedInstance] logoutUser];
    }
    
    if ([notification object]!=nil && [(NSString*)[notification object]isEqualToString:@"email"]) {
        //open login facebook/email
        _rmvc.view.hidden=NO;
        _rmvc.errorLabel.text = NSLocalizedString(@"please_accept_terms",@"");
    }
}

-(void)continueRegisterAfterTermsAccept:(NSNotification*)notification{
    self.termsUIIsopen = NO;
    if ([notification object]!=nil && [[notification object] isKindOfClass:[NSString class]]) {
        [self setUserInteraction:NO];
        NSString * resp = (NSString*)[notification object];
        
        _rmvc.agreeReceiveEmails = ([resp isEqualToString:@"true"]==true) ? true : false;
        
        [_rmvc registerActionInternal];
    }
}

-(void)closeSignInView{
    [self backgroundPressed:nil];
}

- (void) gotoSignUpPressed:(NSNumber*)shouldRemoveFromSuperView {
    if ([shouldRemoveFromSuperView boolValue]) {
        [self dismissUserLoginViewController];
    }
}

- (void) gotoSignUpMailPressed {
    _rmvc = [ControllersFactory instantiateViewControllerWithIdentifier:@"RegistrationMailViewController_iPad" inStoryboard:kLoginStoryboard];

    [self.view bringSubviewToFront:_nav.view];
    [_nav pushViewController:_rmvc animated:YES];
    _rmvc.delegate = self;
    _rmvc.eventLoadOrigin = self.eventLoadOrigin;
}

- (void) gotoForgotPasswordPressed:(NSString *)email {
    _rpvc = [ControllersFactory instantiateViewControllerWithIdentifier:@"RestorePasswordBaseViewController" inStoryboard:kLoginStoryboard];
    _rpvc.strInitialPassword = email;
    [_nav  pushViewController:_rpvc animated:YES];

    _rpvc.delegate = self;
}

- (void) signedUpSuccessfully {
    self.isUserInteractionEnabled = YES;
    [self.userLogInDelegate loginRequestEndedwithState:YES];
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeWindowAfterAction:nil];
//        [self openUserProfileAfterRegister];
    });
}

- (void) signedInSuccessfully {
     self.isUserInteractionEnabled = YES;
    [self.userLogInDelegate loginRequestEndedwithState:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeWindowAfterAction:nil];
    });
}

- (void) termsWizardStatusChange:(BOOL)status{
    self.termsUIIsopen=status;
}

- (BOOL) isTermsWizardWasOpen{
    return  self.termsUIIsopen;
}

-(void)closeWindowAfterAction:(id)sender{
    if ( self.isUserInteractionEnabled) {
        
        if(sender != nil){
            [self.userLogInDelegate loginRequestEndedwithState:NO];
        }
        
        [self dismissUserLoginViewController];
    }
}

- (IBAction)backgroundPressed:(id)sender {
    [self dismissUserLoginViewController];
}

-(void)openFindFriendsAfterRegister{

    // if we in the middle of save design, don't want to disurb the user with that
    UIViewController *cntr = (UIViewController*)[[UIManager sharedInstance] mainViewController];
    if(cntr == nil || (cntr!= nil && [cntr isModal] == NO))
    {
        FindFriendsBaseViewController * ffc = (FindFriendsBaseViewController*)[[UIManager sharedInstance] createUniversalFindFriends];
        [self.parentViewController addChildViewController:ffc];
        [self.view.superview addSubview:ffc.view];
    }
}

-(void)dismissUserLoginViewController{
    
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    }
    
    if (self.openingType == ePush) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.openingType == eModal) {
        [self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    if (self.openingType == eView) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        return;
    }
}

@end
