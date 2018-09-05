//
//  RegistrationViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import "RegistrationViewController_iPhone.h"
#import "NSString+EmailValidation.h"
#import "ControllersFactory.h"
#import "ProfFilterNames.h"
#import "UIView+Alignment.h"

@interface RegistrationViewController_iPhone ()


@property(nonatomic) BOOL                               isTermsOpened;
@property (strong,nonatomic)NSMutableArray              *profItemList;
@property (weak, nonatomic) IBOutlet UIButton           *btnSignUp;
@property (nonatomic) CGRect                            signUpFrame;
@property (nonatomic) CGRect                            activityIndicatorFrame;

@end

@implementation RegistrationViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    _titleLbl.text = NSLocalizedString(@"signin_title", @"");
   
    [_btnSignUp setTitle:NSLocalizedString(@"submit_button", @"") forState:UIControlStateNormal];

    [self initDataProfessions];
    
    self.signUpFrame = self.btnSignUp.frame;
    self.activityIndicatorFrame = self.activityIndicator.frame;
    
    if (![ConfigManager isFaceBookLoginActive]) {
        [self initTextOfStatement:self.lblPrivacyStatementAndTerms];
        [self.lblPrivacyStatementAndTerms setHidden:NO];
    }else{
        [self.lblPrivacyStatementAndTerms setHidden:YES];
    }
}

- (BOOL) isTermsWizardWasOpen{
    return self.isTermsOpened;
}

- (IBAction)signupPressed:(id)sender {
    [super signupPressed:sender];
    
    if (!self.isProfessionalType)
    {
        self.profession=nil;
    }
    else
    {
        if (self.isProfessionalType && self.profession==nil &&[self.dataList count]>0)
        {
            ProfFilterNameItemDO *filterNameDo=self.dataList[0];
            self.profession= filterNameDo.name;
        }
        
        
    }
    //validate email address
    if ([self.email.text isStringValidEmail]==NO)
    {
        return;
    }
    
    //validate password
    if ([self.password.text length] < MIN_PASSOWRD_LENGTH) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContinueRegisterUserAfterTermsAccept" object:@"true"];
}

- (void)privacyPressed:(id)sender {
    [super privacyPressed:sender];
    
    GenericWebViewBaseViewController * iWeb = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] privacyLink]];
    
    [self presentViewController:iWeb animated:YES completion:nil];
}

- (void)openTermsPage:(id)sender {
    [super openTermsPage:sender];
    
    GenericWebViewBaseViewController * iWeb=[[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] termsLink]];
    [self presentViewController:iWeb animated:YES completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField==self.email && [self.password isFirstResponder]) {
        return;
    }
    
    if (textField==self.password && [self.email isFirstResponder]) {
        return ;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)navBack:(id)sender {
    if (self.isOnlyEmailActive) {
        if ([self.delegate respondsToSelector:@selector(navBackPressed)]) {
            [self.delegate performSelector:@selector(navBackPressed)];
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
