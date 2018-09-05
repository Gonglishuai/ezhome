//
//  LoginDefs.h
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import <Foundation/Foundation.h>


#define MIN_PASSOWRD_LENGTH 1

typedef void(^UserLoginCompletionBlock)(BOOL success);

/////////////////////////////////////////////////////////////
/// UserLogInDelegate
@protocol UserLogInDelegate <NSObject>
@optional
- (void)loginWillStart;
- (void)loginRequestCanceled;
- (void)loginRequestEndedwithState:(BOOL)state;
@end

@protocol LogInDelegate <NSObject>
- (void) gotoSignUpPressed;
- (void) gotoSignUpMailPressed;
- (void) gotoForgotPasswordPressed:(NSString *)email;
- (void) setUserInteraction:(Boolean)isEnabled;
- (void) signedInSuccessfully;
- (void) signedUpSuccessfully;
- (void) termsWizardStatusChange:(BOOL)status;
- (BOOL) isTermsWizardWasOpen;
- (void) navBackPressed;
@end


