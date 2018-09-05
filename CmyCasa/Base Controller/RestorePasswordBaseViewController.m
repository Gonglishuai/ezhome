//
//  RestorePasswordBaseViewController.m
//  Homestyler
//
//  Created by Maayan Zalevas on 8/18/14.
//
//

#import "RestorePasswordBaseViewController.h"
#import "UITextField+NUI.h"

@interface RestorePasswordBaseViewController () <UITextFieldDelegate>
{
}


@end

@implementation RestorePasswordBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.strInitialPassword != nil)
    {
        self.email.text = self.strInitialPassword;
    }
        
    [self.activityIndicator stopAnimating];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)forgotPasswordPressed:(id)sender {
    
    self.errorLabel.text = @"";
    [self.email resignFirstResponder];
    
    //validate email address
    if ([self.email.text isStringValidEmail]==NO) {
        self.errorLabel.text = NSLocalizedString(@"illigal_email",@"Please enter a valid email, like stylerlover@yourmail.com");
        self.email.layer.borderColor = [[UIColor redColor] CGColor];
        return;
    }
    
    if ([ConfigManager showMessageIfDisconnected]) {
        return;
    }
    
    [self setUserInteraction:NO];
    
    if (self.delegate != nil) {
        [self.delegate setUserInteraction:NO];
    }
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOGIN_CLICK_LOGIN_SCREEN withParameters:@{EVENT_PARAM_NAME_CLICK_OPTION:EVENT_PARAM_VAL_SIGN_IN_CLICK_OPTION_PASSWORD}];
    
    [[UserManager sharedInstance] userForgotPassword:self.email.text completionBlock:^(id serverResponse, id error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error) {
                self.errorLabel.text = NSLocalizedString(@"forgot_password_ok",@"A new password has been sent to your email.");
            }else{
                self.errorLabel.text = NSLocalizedString(@"forgot_password_error",@"Enter the email you used to sign up.");
                
            }
            
            [self setUserInteraction:YES];
        });
        
        if (self.delegate != nil) {
            [self.delegate setUserInteraction:YES];
        }
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void) setUserInteraction:(Boolean) isEnabled {
    [self.coverView setHidden:isEnabled];
    
    if (isEnabled) {
        [self.activityIndicator stopAnimating];
    }
    else {
        [self.activityIndicator startAnimating];
    }
}

- (IBAction)backPressed:(id)sender {
    [self.email resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _errorLabel.text = @"";
    if ([textField respondsToSelector:@selector(applyNUI)])
    {
        [textField performSelector:@selector(applyNUI)];
    }

    return YES;
}


@end
