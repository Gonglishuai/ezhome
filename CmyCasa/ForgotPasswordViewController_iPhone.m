//
//  iphoneForgotPasswordViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/10/13.
//
//

#import "ForgotPasswordViewController_iPhone.h"
#import "UITextField+NUI.h"

@interface ForgotPasswordViewController_iPhone ()

@end

@implementation ForgotPasswordViewController_iPhone


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) colorTextField:(UITextField*) textField :(UIColor*) color {

}

- (IBAction)editingBegin:(id)sender {
    [self colorTextField:self.emailText:[UIColor clearColor]];
    self.errorLabel.text = @"";
}

- (IBAction)editingEnd:(id)sender {
    [self colorTextField:self.emailText:[UIColor clearColor]];
     self.errorLabel.text = @"";
}

- (IBAction)restorePassAction:(id)sender {
    
    [self colorTextField:self.emailText:[UIColor clearColor]];
    [self.emailText resignFirstResponder];
    
    self.errorLabel.text = @"";
    
    //validate email address
    if ([self.emailText.text isStringValidEmail] == NO) {
        [self colorTextField:self.emailText:[UIColor redColor]];
        self.errorLabel.text = NSLocalizedString(@"illigal_email", @"Please enter a valid email, like stylerlover@yourmail.com");
        self.emailText.layer.borderColor = [[UIColor redColor] CGColor];
        return;
    }
    
    [self.view setUserInteractionEnabled:NO];
    
    [self.indicator startAnimating];
    
    [[UserManager sharedInstance] userForgotPassword:self.emailText.text completionBlock:^(id serverResponse, id error) {
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           if (error == nil) {
                               self.errorLabel.text = NSLocalizedString(@"forgot_password_ok", @"A new password has been sent to your email.");
                           }else{
                               self.errorLabel.text = NSLocalizedString(@"forgot_password_error", @"Enter the email you used to sign up.");
                           }
                           
                           
                           [self.view setUserInteractionEnabled:YES];
                           [self.indicator stopAnimating];
                       });
        
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)navBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.errorLabel.text = @"";
    if ([textField respondsToSelector:@selector(applyNUI)])
    {
        [textField performSelector:@selector(applyNUI)];
    }
    
    return YES;
}

@end
