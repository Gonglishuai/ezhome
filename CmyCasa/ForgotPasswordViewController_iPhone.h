//
//  iphoneForgotPasswordViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 6/10/13.
//
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController_iPhone : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction)restorePassAction:(id)sender;
- (IBAction)navBack:(id)sender;

@end
