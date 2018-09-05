//
//  RestorePasswordBaseViewController.h
//  Homestyler
//
//  Created by Maayan Zalevas on 8/18/14.
//
//

#import <UIKit/UIKit.h>
#import "LoginDefs.h"

@interface RestorePasswordBaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) id <LogInDelegate> delegate;

@property (nonatomic, strong) NSString *strInitialPassword;

@end
