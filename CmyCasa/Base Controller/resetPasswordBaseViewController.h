//
//  ResetPasswordBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import <UIKit/UIKit.h>

@interface ResetPasswordBaseViewController : UIViewController{
    
    @protected
     NSCharacterSet *blockedCharacters;
}

@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *resetPassButton;
@property (weak, nonatomic) IBOutlet UITextField *nwPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *cancelResetButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSign;

- (IBAction)cancelResetPass:(id)sender;
- (IBAction)resetPassword:(id)sender;

@end
