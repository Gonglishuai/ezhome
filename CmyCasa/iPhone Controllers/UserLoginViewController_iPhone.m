//
//  iphoneUserLoginViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "UserLoginViewController_iPhone.h"
#import "UserLoginOptionsViewController_iPhone.h"
#import "RegistrationViewController_iPhone.h"
#import "FindFriendsBaseViewController.h"
#import "UIViewController+Helpers.h"
#import "ControllersFactory.h"

@interface UserLoginViewController_iPhone ()

@property (nonatomic,strong) UserLoginOptionsViewController_iPhone * loginOptionsViewController;
@property (nonatomic,strong) RegistrationViewController_iPhone * rvc;

@end

@implementation UserLoginViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ([ConfigManager isFaceBookLoginActive]) {
        _isFaceBookActive = YES;
    }
    
    if ([ConfigManager isEmailLoginActive]) {
        _isEmailActive = YES;
    }
    
    //Special Case
    if (!_isFaceBookActive) {
        self.rvc =[ControllersFactory instantiateViewControllerWithIdentifier:@"RegistrationMailViewController_iPad" inStoryboard:kLoginStoryboard];
        self.rvc.eventLoadOrigin = self.eventLoadOrigin;
        self.rvc.delegate = self;
        self.rvc.isOnlyEmailActive = YES;
        [self.navigationController pushViewController:self.rvc animated:YES];
    }else{
        self.loginOptionsViewController=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginOptionsController" inStoryboard:kLoginStoryboard];
        self.loginOptionsViewController.eventLoadOrigin = self.eventLoadOrigin;
        self.loginOptionsViewController.delegate = self;
        [self.navigationController pushViewController:self.loginOptionsViewController animated:NO];
    }
}

-(void) navBackPressed{
    
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SinginControllerCanceledWithoutAction" object:nil];
    
    if (self.openingType==ePush) {
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (self.openingType==eModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.openingType==eView) {
        [self.navigationController.view removeFromSuperview];
        return;
    }
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

-(void)closeWindowAfterAction:(id)sender{
    if (self.isUserInteractionEnabled) {
        if(sender != nil){
            [self.userLogInDelegate loginRequestEndedwithState:NO];
        }
        [self closeSignInView];
    }
}

-(void)closeSignInView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)facebookLoginFailed:(NSNotification *)notification{
    
    NSString * res = [notification object];
    NSString * err = [[HSErrorsManager sharedInstance] getErrorByGuidLocalized:res];
    if (err) {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                             
                                                       message:err delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")  otherButtonTitles: nil];
        
        [alert show];
    }
    [self.loginOptionsViewController.facebookIndicator stopAnimating];

    [self.userLogInDelegate loginRequestEndedwithState:NO];
}

-(void)facebookLoginDone:(NSNotification*)notification{
    [self.userLogInDelegate loginRequestEndedwithState:YES];
    [self closeSignInView];
}

-(void)acceptTermsFinishedNotification:(NSNotification*)notification{
    [self closeSignInView];
    [self.userLogInDelegate loginRequestEndedwithState:YES];
    [self signedUpSuccessfully];
}

-(void)termsDeclined:(NSNotification*)notification{
    
    if ([notification object]!=nil && [(NSString*)[notification object]isEqualToString:@"facebook"]) {

        [self.userLogInDelegate loginRequestEndedwithState:NO];

        [[AppCore sharedInstance] logoutUser];
    }
    if ([notification object]!=nil && [(NSString*)[notification object]isEqualToString:@"email"]) {
        
        UIViewController * vw=[self.navigationController topViewController];
        
        if ([vw isKindOfClass:[RegistrationViewController_iPhone class]]) {
            //in the middle of registration
            RegistrationViewController_iPhone * iph=(RegistrationViewController_iPhone *)vw;
            iph.errorLabel.text=NSLocalizedString(@"please_accept_terms",@"");
        }
    }
}

-(void)continueRegisterAfterTermsAccept:(NSNotification*)notification{
    
    if ([notification object]!=nil && [[notification object] isKindOfClass:[NSString class]]) {
        [self setUserInteraction:NO];
        NSString * resp=(NSString*)[notification object];
        
        UIViewController * vw=[self.navigationController topViewController];
        
        if ([vw isKindOfClass:[RegistrationViewController_iPhone class]]) {
            //in the middle of registration
            RegistrationViewController_iPhone * iph=(RegistrationViewController_iPhone *)vw;
            iph.agreeReceiveEmails=([resp isEqualToString:@"true"]==true)?true:false;
            [iph registerActionInternal];
        }
    }
}

-(void)dealloc{
    NSLog(@"dealloc - UserLoginViewController_iPhone");
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)openFindFriendsAfterRegister{
    
    // if we in the middle of save design, don't want to disurb the user with that
    UIViewController *cntr = (UIViewController*)[[UIManager sharedInstance] mainViewController];
    if(cntr == nil || (cntr!=nil && [cntr isModal]==false))
    {
        FindFriendsBaseViewController * ffc =  (FindFriendsBaseViewController*)[[UIManager sharedInstance] createUniversalFindFriends];
        [[[[UIManager sharedInstance] pushDelegate] navigationController]pushViewController:ffc animated:YES];
    }
}

@end
