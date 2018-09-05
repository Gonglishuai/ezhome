//
//  iphoneSettingsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsBaseViewController.h"


@interface IphoneSettingsViewController : SettingsBaseViewController <IphoneMenuManagerDelegate, UIAlertViewDelegate>


- (IBAction)openMenu:(id)sender;

@end
