//
//  UserLoginOptionsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "HSViewController.h"
#import "LoginDefs.h"
#import "TTTAttributedLabel.h"

@interface UserLoginOptionsBaseViewController : HSViewController<UIAlertViewDelegate, TTTAttributedLabelDelegate>{
    BOOL _isFaceBookActive;
    BOOL _isEmailActive;
}

@property (weak, nonatomic) id <LogInDelegate> delegate;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblPrivacyStatementAndTerms;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookIndicator;
@property (weak, nonatomic) IBOutlet UIView * facebookView;
@property (weak, nonatomic) IBOutlet UIView * emailView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *userTip;

- (IBAction)facebookPressed:(id)sender;
- (IBAction)signupPressed:(id)sender;

- (void)initTextOfStatement:(TTTAttributedLabel*)label;


@end
