//
//  MenuViewController.h
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import <UIKit/UIKit.h>

#import "MenuBaseViewController.h"
#import "UIManager.h"
#import "ExternalLoginViewController.h"
#import "LoginDefs.h"

@interface MenuViewController : MenuBaseViewController <UserLogInDelegate>


- (IBAction)closeMenuOverlay:(id)sender;
- (int)getIndexOfSelectedMenuButton;

@end
