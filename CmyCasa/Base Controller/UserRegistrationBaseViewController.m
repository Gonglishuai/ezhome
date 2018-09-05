//
//  UserRegistrationBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "UserRegistrationBaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FlurryDefs.h"
#import "UserManager.h"
#import "NSString+EmailValidation.h"
#import "ProfFilterNames.h"
#import "ProgressPopupViewController.h"
#import "UIView+NUI.h"
#import "NSString+Contains.h"

@interface UserRegistrationBaseViewController ()
{
}

@property(nonatomic) ProfFilterNames*  filterNames;

@property (weak, nonatomic) IBOutlet UIView * bgViewForEmail;
@property (weak, nonatomic) IBOutlet UIView * bgViewForPassword;

@end

@implementation UserRegistrationBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.agreeReceiveEmails = NO;
    [self setUserInteraction:YES];
    
    if (![ConfigManager isForgotPasswordActive]) {
        [self.btnForgotPass setHidden:YES];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self markView:self.email isValid:YES];
    [self markView:self.password isValid:YES];
    
    if (IS_IPAD) {
        if (self.delegate && [self.delegate isTermsWizardWasOpen]==false) {
            self.errorLabel.text = @"";
            self.email.text = @"";
            self.password.text = @"";
        }
    }else{
        if ([self isTermsWizardWasOpen]==false) {
            self.errorLabel.text = @"";
            self.email.text = @"";
            self.password.text = @"";
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)setUserInteraction:(Boolean) isEnabled {
    [self.coverView setHidden:isEnabled];
    
    if (isEnabled) {
        [self.activityIndicator stopAnimating];
    }
    else {
        [self.activityIndicator startAnimating];
    }
}

- (void)colorTextField:(UIView*) textField :(UIColor*) color
{
}

- (void)markView:(UIView*)view isValid:(BOOL)isValid {
        if (isValid) {
            if ([view respondsToSelector:@selector(applyNUI)])
            {
                [view performSelector:@selector(applyNUI)];
            }
        }
        else {
            view.layer.borderColor = [[UIColor redColor] CGColor];
        }
        view.clipsToBounds      = YES;
}

-(void)registerActionInternal{
    
    BOOL isProfessional = self.isProfessionalType;
    
    if ([ConfigManager showMessageIfDisconnected]) {
        return;
    }
    
    [self setUserInteraction:NO];
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_EMAIL_SIGNUP_SUBMIT withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:self.eventLoadOrigin}];
    
    [[UserManager sharedInstance]
     userRegister:self.email.text withPass:self.password.text isProf:isProfessional withProf:self.profession agreeEmails:self.agreeReceiveEmails
     completionBlock:^(id serverResponse,id error) {
         
         if (!error) {
             [self setUserInteraction:YES];
             
             
             if (self.delegate != nil) {
                 [self.delegate setUserInteraction:YES];
             }
             
             NSString *myLocalizableString = [NSString localizedStringCustom:@"signup_ok"];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                 message:[NSString stringWithFormat:myLocalizableString, [ConfigManager getAppName]]
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"alert_action_ok",@"")
                                                       otherButtonTitles:nil];
                 [alert show];
                 
             });
             
             if ([self.delegate respondsToSelector:@selector(signedUpSuccessfully)]) {
                 [self.delegate performSelector:@selector(signedUpSuccessfully)];
             }
         }else{
             [self.btnForgotPass setEnabled:YES];
             
             //HANDLE Error
             NSString * err = [[HSErrorsManager sharedInstance] getErrorByGuidLocalized:error];
             HSServerErrorCode errorCode=[[HSErrorsManager sharedInstance] getErrorCodeByGuid:error];
             if (errorCode==HSERR_EMAIL_ALREADY_EXISTS) {
                 
                 [self loginOnSignupExisting];
                 
             }else{
                 if (self.delegate != nil) {
                     [self.delegate setUserInteraction:YES];
                 }
                 
                 [self setUserInteraction:YES];
                 
                 if (err) {
                     self.errorLabel.text = err;
                 }else
                     self.errorLabel.text = NSLocalizedString(@"register_error",@"Could not register");
             }
             
         }
     } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (IBAction)signupPressed:(id)sender {
    [self.btnForgotPass setEnabled:NO];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    UIView * emailViewForMarking = self.bgViewForEmail ? self.bgViewForEmail : self.email;
    UIView * pwViewForMarking = self.bgViewForPassword ? self.bgViewForPassword : self.password;
    
    [self markView:emailViewForMarking isValid:YES];
    [self markView:pwViewForMarking isValid:YES];
    self.errorLabel.text = @"";
    
    //validate email address
    if ([self.email.text isStringValidEmail]==NO) {
        [self markView:emailViewForMarking isValid:NO];
        [self.btnForgotPass setEnabled:YES];
        self.errorLabel.text = NSLocalizedString(@"illigal_email",@"Please enter a valid email, like stylerlover@yourmail.com");
        return;
    }
    
    //validate password
    if ([self.password.text length] < MIN_PASSOWRD_LENGTH) {
        [self markView:pwViewForMarking isValid:NO];
        [self.btnForgotPass setEnabled:YES];
        self.errorLabel.text = NSLocalizedString(@"illigal_password",@"Almost there! Your password should be at least 1 character long.");
        return;
    }
}

-(void)loginOnSignupExisting{
  
    [[UserManager sharedInstance]userLoginWithEmail:self.email.text
                                           withPass:self.password.text
                                isPassAlreadyHashed:NO
                                    completionBlock:^(id serverResponse, id error) {
                                        
                                        if (!error) {
                                            if ([self.delegate respondsToSelector:@selector(signedInSuccessfully)]) {
                                                [self.delegate performSelector:@selector(signedInSuccessfully)];
                                            }
                                        }else{
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.activityIndicator stopAnimating];
                                                self.errorLabel.text = NSLocalizedString(@"login_error_after_signup",@"This email is already part of the Homestyler community. Check your password and try again.");
                                            });
                                        }
                                    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (IBAction)backPressed:(id)sender {
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
}

- (void)privacyPressed:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_READ_POLICY_CLICK];
    }
#endif
}

- (IBAction)editingBegin:(id)sender {
    [self markView:self.email isValid:YES];
    [self markView:self.password isValid:YES];
}

- (IBAction)editingEnd:(id)sender {
    [self markView:self.email isValid:YES];
    [self markView:self.password isValid:YES];
}

- (void)openTermsPage:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_READ_TERMS_CLICK];
    }
#endif
}

- (BOOL) isTermsWizardWasOpen{
    return NO;
}

-(void)initDataProfessions
{
    self.filterNames = [[ProfFilterNames alloc]initWithDict:[NSArray array]];
    
    [[[AppCore sharedInstance] getProfsManager] getProffesionalFiltersWithCompletionBlock:^ (ProfFilterNames *names)
     {
         if (names)
         {
             self.filterNames = names;
             
             if ([self.filterNames isFiltersReady] == NO)
             {
                 HSMDebugLog(@"getProfFilters return %lu combo entries", (unsigned long)[_combos count]);
                 return;
             }
             
             self.dataList = self.filterNames.professions;
             //The first cell is "all"
             [self.dataList removeObjectAtIndex:0];
         }
     }];
}


- (IBAction)forgotPasswordPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(gotoForgotPasswordPressed:)]) {
        [self.delegate performSelector:@selector(gotoForgotPasswordPressed:) withObject:self.email.text];
    }
}

#pragma mark - TTTAttributedLabelDelegate

- (void)initTextOfStatement:(TTTAttributedLabel*)label
{
    label.delegate=self;
    
    NSString * formated = [NSString stringWithFormat:NSLocalizedString (@"autodesk_privacy_statement_and_terms_of_service",""),NSLocalizedString (@"autodesk_privacy_statement",""),NSLocalizedString(@"terms_of_service", "")];
    
    NSString *labelText = [NSString stringWithFormat:@"%@.", formated];
    label.text = labelText ;
    NSRange rangePrivecyStatemnt = [labelText rangeOfString:NSLocalizedString (@"autodesk_privacy_statement","")];
    NSRange rangeTermsOfService=[labelText rangeOfString:NSLocalizedString(@"terms_of_service", "")];
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName
                     , nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:(88/255.0) green:(165/255.0) blue:(204/255.0) alpha:1],[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    
    label.linkAttributes = linkAttributes;
    label.numberOfLines = 0;
    [label addLinkToURL:[NSURL URLWithString:[[ConfigManager sharedInstance] privacyLink]] withRange:rangePrivecyStatemnt];
    [label addLinkToURL:[NSURL URLWithString:[[ConfigManager sharedInstance] termsLink]] withRange:rangeTermsOfService];
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    NSString *privecyUrl= (NSString*)[[ConfigManager sharedInstance] privacyLink];
    NSString *currUrl= [NSString stringWithFormat:@"%@",url];
    
    if ([currUrl isEqualToString:privecyUrl])
    {
        GenericWebViewBaseViewController * iWeb=[[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] privacyLink]];
        [self presentViewController:iWeb animated:YES completion:nil];
    }
    else
    {
        GenericWebViewBaseViewController * iWeb=[[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] termsLink]];
        [self presentViewController:iWeb animated:YES completion:nil];
    }
}

@end
