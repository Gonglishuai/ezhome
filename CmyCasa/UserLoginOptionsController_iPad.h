//
//  UserLoginOptionsController_iPad.h
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import <UIKit/UIKit.h>
#import "UserLoginOptionsBaseViewController.h"
#import "LoginDefs.h"

@class GPPSignInButton;

@interface UserLoginOptionsController_iPad : UserLoginOptionsBaseViewController

- (IBAction)facebookPressed:(id)sender;
- (IBAction)signupPressed:(id)sender;

@end
