//
//  RegistrationMailViewController_iPad.h
//  CmyCasa
//
//  Created by Dor Alon on 12/27/12.
//
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "UserRegistrationBaseViewController.h"



@interface RegistrationMailViewController_iPad : UserRegistrationBaseViewController <UIPopoverControllerDelegate>
@property (nonatomic, assign) BOOL isOnlyEmailActive;
@property (nonatomic, assign) BOOL isAnimationActive;
@property (nonatomic, strong) IBOutlet UIView * signUpViewContainer;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel * lblPrivacyStatementAndTerms;
@property (nonatomic, strong) IBOutlet UIButton * btnSignUp;
@property (nonatomic)int indexChecked;

@end
