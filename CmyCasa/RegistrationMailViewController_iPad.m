//
//  RegistrationMailViewController_iPad.m
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import "RegistrationMailViewController_iPad.h"
#import "NSString+EmailValidation.h"
#import "ControllersFactory.h"
#import "ProfFilterNames.h"
#import "TTTAttributedLabel.h"
#import <QuartzCore/QuartzCore.h>


@interface RegistrationMailViewController_iPad ()



@end

@implementation RegistrationMailViewController_iPad

- (void)viewDidLoad{
    [super viewDidLoad];
    self.isAnimationActive = NO;
    self.isProfessionalType = NO;
    [self.activityIndicator stopAnimating];
    [self initDataProfessions];
    
    if (![ConfigManager isForgotPasswordActive]) {
        [self.btnForgotPass setHidden:YES];
    }
    
    [_btnSignUp setTitle:NSLocalizedString(@"submit_button", @"") forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification) name:UIKeyboardWillHideNotification object:nil];
    
    if (![ConfigManager isFaceBookLoginActive]) {
        [self initTextOfStatement:self.lblPrivacyStatementAndTerms];
        [self.lblPrivacyStatementAndTerms setHidden:NO];
    }else{
        [self.lblPrivacyStatementAndTerms setHidden:YES];
    }
}

- (IBAction)signupPressed:(id)sender {
    [super signupPressed:sender];
    
    UIButton *button = sender;
    button.selected=YES;
 
    //validate email address
    if ([self.email.text isStringValidEmail]==NO) {
          return;
    }
        
    //validate password
    if ([self.password.text length] < MIN_PASSOWRD_LENGTH) {
        return;
    }
    if (!self.isProfessionalType)
    {
        self.profession=nil;
    }
    else
    {
        if (!self.indexChecked && [self.dataList count]>0)
        {
            ProfFilterNameItemDO *filterNameDo=self.dataList[0];
            self.profession= filterNameDo.name;
        }
    }
    
    [self registerActionInternal];
}

- (IBAction)backPressed:(id)sender {
    [super backPressed:sender];
    
    BOOL shouldRemoveFromSuperView = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.isOnlyEmailActive) {
        shouldRemoveFromSuperView = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(gotoSignUpPressed:)]) {
        [self.delegate performSelector:@selector(gotoSignUpPressed:) withObject:[NSNumber numberWithBool:shouldRemoveFromSuperView]];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.errorLabel.text = @"";
}

-(void)closeAnimation{
}

-(void)keyboardWillHideNotification{
}

@end
