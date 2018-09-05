//
//  UserLoginViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import <UIKit/UIKit.h>
#import "UserLoginOptionsController_iPad.h"
#import "RegistrationMailViewController_iPad.h"

#import "UserLoginBaseViewController.h"
#import "RestorePasswordBaseViewController.h"



@interface UserLoginViewController : UserLoginBaseViewController
{
    UserLoginOptionsController_iPad * _signUpViewController;
    RegistrationMailViewController_iPad * _rmvc;
    RestorePasswordBaseViewController * _rpvc;

    BOOL _isFaceBookActive;
    BOOL _isEmailActive;
}

@property(nonatomic)  BOOL termsUIIsopen;

- (IBAction)backgroundPressed:(id)sender;
- (void) gotoSignUpPressed:(NSNumber*)shouldRemoveFromSuperView;
- (void)dismissUserLoginViewController;

@end
