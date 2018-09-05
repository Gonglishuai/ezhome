//
//  ResetPasswordBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "ResetPasswordBaseViewController.h"
#import "LoginDefs.h"
#import <QuartzCore/QuartzCore.h>
#import "HelpersRO.h"

@interface ResetPasswordBaseViewController ()

@property (weak, nonatomic) IBOutlet UIView *bgViewCurrentPW;
@property (weak, nonatomic) IBOutlet UIView *bgViewNewPW;
@property (weak, nonatomic) IBOutlet UIView *bgViewConfirmPW;

@end

@implementation ResetPasswordBaseViewController

-(void)viewWillAppear:(BOOL)animated {
    
    self.errorLabel.text=@"";
    self.currentPasswordField.text=@"";
    self.confirmPasswordField.text=@"";
    self.nwPasswordField.text=@"";
    
    if (!CGAffineTransformIsIdentity(self.parentViewController.view.transform)) {
        CGPoint p = self.parentViewController.view.center;
        self.view.center = CGPointMake(p.y, p.x);
    } else {
        self.view.center = self.parentViewController.view.center;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    blockedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\";/"];
}

- (IBAction)cancelResetPass:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)resetPassword:(id)sender {
    NSString* strState = NSLocalizedString(@"success_msg_pass_updated",@"Your password updated successfully");
    
    if([self.errorLabel.text isEqualToString: strState])
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        return;
        
    }
    
    NSString* accout;
    if ([[[UserManager sharedInstance]currentUser] usertype] == kUserTypePhone) {
        accout = [[[UserManager sharedInstance]currentUser] userPhone];
    } else {
        accout = [[[UserManager sharedInstance]currentUser] userEmail];
    }
    NSString* password =  [[[UserManager sharedInstance]currentUser] userPassword];
    
    /*
     Make sure to color the right visual element
     */
    
    UIView * newPW = self.bgViewNewPW ? self.bgViewNewPW : self.nwPasswordField;
    UIView * curPW = self.bgViewCurrentPW ? self.bgViewCurrentPW : self.currentPasswordField;
    UIView * confirmPW = self.bgViewConfirmPW ? self.bgViewConfirmPW : self.confirmPasswordField;
    
    [self colorTextField:newPW isValid:YES];
    [self colorTextField:curPW isValid:YES];
    [self colorTextField:confirmPW isValid:YES];
    
    
    [self.nwPasswordField resignFirstResponder];
    [self.currentPasswordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
    
    if (password==nil || accout==nil) {
        
        self.errorLabel.text=NSLocalizedString(@"err_msg_login_before_pass_reset",@"You must login before changing your current password");
        return;
    }
    
    
    //NSString* encodedPassword = [HelpersRO encodeMD5:self.currentPasswordField.text];
    NSString* encodedPassword = self.currentPasswordField.text;
    
    if ([password isEqualToString:encodedPassword]==false) {
        
        self.errorLabel.text=NSLocalizedString(@"err_msg_pass_incorrect",@"Your current password is incorrect");
        [self colorTextField:curPW isValid:NO];
        
        return;
    }
    
    if ([self.nwPasswordField.text length]==0) {
        
        self.errorLabel.text=NSLocalizedString(@"err_msg_enter_new_pass",@"Please enter new password");
        [self colorTextField:newPW  isValid:NO];
        return;
    }
    
    if ([self.nwPasswordField.text length] < MIN_PASSOWRD_LENGTH) {
        [self colorTextField:newPW  isValid:NO];
        self.errorLabel.text = NSLocalizedString(@"illigal_password",@"Almost there! Your password should be at least 1 character long.");
        return;
    }
    
    if ([self.nwPasswordField.text isEqualToString:self.confirmPasswordField.text]==false) {
        
        self.errorLabel.text=NSLocalizedString(@"err_msg_pass_confirm_mismatch",@"New password and confirm password don't match");
        [self colorTextField:confirmPW isValid:NO];
        
        return;
    }

    self.errorLabel.text=@"";
    [self.loadingSign startAnimating];
 
    [self setUserInteraction:NO];
    
    [[UserManager sharedInstance] updateUserPassword:self.nwPasswordField.text completionBlock:^(id serverResponse, id error) {
        
       dispatch_async(dispatch_get_main_queue(), ^{
           
           [self setUserInteraction:YES];
           
           if (error) {
               self.errorLabel.text = NSLocalizedString(@"err_msg_pass_change_failed",@"Password change failed");
               
           }else{
               BaseResponse * response = (BaseResponse*)serverResponse;
               if (response && response.errorCode==-1) {
                   self.errorLabel.text = NSLocalizedString(@"success_msg_pass_updated",@"Your password updated successfully");
               }else{
                   self.errorLabel.text = NSLocalizedString(@"err_msg_pass_change_failed",@"Password change failed");
               }
           }
       });
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void) colorTextField:(UIView*)textField isValid:(BOOL)isValid {
    
    if(!IS_IPAD) {
        if (isValid) {
            textField.layer.borderWidth = 1.0f;
            textField.layer.borderColor = [[UIColor colorWithRed:214.f/255.f green:214.f/255.f blue:214.f/255.f alpha:0.8f] CGColor];
            
        }
        else {
            textField.layer.borderWidth = 2.0f;
            textField.layer.borderColor = [[UIColor redColor] CGColor];
        }
        textField.clipsToBounds      = YES;
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.errorLabel.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    if (textField==self.currentPasswordField && ([self.nwPasswordField isFirstResponder] || [self.confirmPasswordField isFirstResponder])) {
        
        return;
    }
    if (textField==self.nwPasswordField && ([self.currentPasswordField isFirstResponder] || [self.confirmPasswordField isFirstResponder])) {
        
        return;
    }
    
    if (textField==self.confirmPasswordField && ([self.nwPasswordField isFirstResponder] || [self.currentPasswordField isFirstResponder])) {
        
        return;
    }
}

- (void) setUserInteraction:(Boolean) isEnabled {
    
    [self.resetPassButton setEnabled:isEnabled];
    [self.cancelResetButton setEnabled:isEnabled];
    
    if (isEnabled) {
        [self.loadingSign stopAnimating];
    }
    else {
        [self.loadingSign startAnimating];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return ([text rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
}

@end
