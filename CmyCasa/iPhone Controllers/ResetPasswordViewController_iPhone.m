//
//  iphoneResetPasswordViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "ResetPasswordViewController_iPhone.h"

@interface ResetPasswordViewController_iPhone ()

@end

@implementation ResetPasswordViewController_iPhone

-(void)viewWillAppear:(BOOL)animated{
  
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:NO];
}

-(BOOL)shouldAutorotate{
    return NO;
}

- (IBAction)cancelResetPass:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)resetPassword:(id)sender {
    NSString* strState = NSLocalizedString(@"success_msg_pass_updated",@"Your password updated successfully");
    
    if([self.errorLabel.text isEqualToString: strState])
    {
        [self cancelResetPass:nil];
        return;
    }
    [super resetPassword:sender];
}


@end
