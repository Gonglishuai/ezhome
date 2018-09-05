//
//  UserRegistrationBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/30/13.
//
//

#import <UIKit/UIKit.h>
#import "LoginDefs.h"
#import "ProfFilterNames.h"
#import "TTTAttributedLabel.h"

@interface UserRegistrationBaseViewController : HSViewController<UITextFieldDelegate,UIAlertViewDelegate,TTTAttributedLabelDelegate>

@property(nonatomic)BOOL agreeReceiveEmails;
@property (weak, nonatomic) id <LogInDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton * btnForgotPass;
@property (strong,nonatomic) NSString* profession;
@property (nonatomic,strong) NSMutableArray* combos;
@property (strong,nonatomic)NSMutableArray *dataList;
@property (nonatomic) BOOL isProfessionalType;

- (void)openTermsPage:(id)sender;
- (void)registerActionInternal;
- (IBAction)signupPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (void)privacyPressed:(id)sender;
- (IBAction)editingBegin:(id)sender;
- (IBAction)editingEnd:(id)sender;
- (void)initDataProfessions;
- (IBAction)forgotPasswordPressed:(id)sender;
- (void)initTextOfStatement:(TTTAttributedLabel*)label;
@end
