//
//  SignUpViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import "UserLoginOptionsController_iPad.h"

@interface UserLoginOptionsController_iPad ()

@end

@implementation UserLoginOptionsController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTextOfStatement:self.userTip];
    [self initTextOfStatement:self.lblPrivacyStatementAndTerms];
}

-(void)dealloc{
    NSLog(@"dealloc - UserLoginOptionsController_iPad");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.facebookIndicator stopAnimating];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)facebookPressed:(id)sender {
    [super facebookPressed:sender];
    [self.facebookIndicator stopAnimating];
}

- (IBAction)signupPressed:(id)sender {
    [super signupPressed:sender];
  
    if ([self.delegate respondsToSelector:@selector(gotoSignUpMailPressed)]) {
        [self.delegate performSelector:@selector(gotoSignUpMailPressed)];
    }
}

-(IBAction)btnCloseSignupView:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(dismissUserLoginViewController)]) {
        [self.delegate performSelector:@selector(dismissUserLoginViewController)];
    }
}

@end


