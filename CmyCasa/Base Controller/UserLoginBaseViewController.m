//
//  UserLoginBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import "UserLoginBaseViewController.h"
#import "NewBaseProfileViewController.h"
#import "ControllersFactory.h"


@interface UserLoginBaseViewController ()

@end

@implementation UserLoginBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isUserInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginDone:) name:@"SinginFacebookCompleteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginFailed:) name:@"SinginFacebookFailedCompleteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(termsDeclined:) name: @"AcceptTermsDeclinedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(continueRegisterAfterTermsAccept:) name: @"ContinueRegisterUserAfterTermsAccept" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptTermsFinishedNotification:) name: @"AcceptTermsFinishedNotification" object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SinginFacebookCompleteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SinginFacebookFailedCompleteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AcceptTermsDeclinedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ContinueRegisterUserAfterTermsAccept" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AcceptTermsFinishedNotification" object:nil];
}

#pragma mark - LogInDelegate
- (void) gotoSignUpPressed{
    
}

- (void) gotoSignUpMailPressed{
    
}

- (void) gotoForgotPasswordPressed:(NSString *)email {
    
}

- (void) gotoSignInPressed{
    
}

- (void) setUserInteraction:(Boolean)isEnabled {
    self.isUserInteractionEnabled = isEnabled;
}

- (void) signedInSuccessfully{
    
}

- (void) signedUpSuccessfully{
    
}

- (void) termsWizardStatusChange:(BOOL)status{
    
}

- (BOOL) isTermsWizardWasOpen{
    return NO;
}

- (void) navBackPressed{
    
}

#pragma mark - Notification
-(void)facebookLoginDone:(NSNotification*)notification{
    
}


-(void)facebookLoginFailed:(NSNotification *)notification{
    
}

-(void)termsDeclined:(NSNotification*)notification{
    
}

-(void)continueRegisterAfterTermsAccept:(NSNotification*)notification{
    
}

-(void)acceptTermsFinishedNotification:(NSNotification*)notification{
    
}

#pragma mark - Class Function
-(void)openFindFriendsAfterRegister{
    
}

-(void)openUserProfileAfterRegister{
    
    NewBaseProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    [NewBaseProfileViewController needToRefreshProfile:NO];
        
    [profileViewController setUserId:[[[UserManager sharedInstance] currentUser] userID]];
    [profileViewController startProfileEditingAfterRegistration];
    
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
}

@end
