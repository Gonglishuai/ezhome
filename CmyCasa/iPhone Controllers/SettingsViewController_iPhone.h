//
//  SettingsViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <UIKit/UIKit.h>
#import "SettingsBaseViewController.h"


@interface SettingsViewController_iPhone : SettingsBaseViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel * versionLbl;
@end
