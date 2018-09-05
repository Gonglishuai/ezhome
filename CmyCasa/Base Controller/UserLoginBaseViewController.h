//
//  UserLoginBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/29/13.
//
//

#import <UIKit/UIKit.h>
#import "LoginDefs.h"

typedef enum LoginOpenType
{
    eModal =  1,
    ePush  =  2,
    eView  =  3
} LoginViewType;

@interface UserLoginBaseViewController : HSViewController<LogInDelegate>

@property (weak, nonatomic) id <UserLogInDelegate> userLogInDelegate;
@property (nonatomic) Boolean isUserInteractionEnabled;
@property (nonatomic) LoginViewType openingType;

-(void)openFindFriendsAfterRegister;
-(void)openUserProfileAfterRegister;
-(void)setUserInteraction:(Boolean)isEnabled;

@end
