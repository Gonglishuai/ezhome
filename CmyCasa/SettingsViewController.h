//
//  SettingsViewController.h
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SettingsBaseViewController.h"
#import "ProfileViewController.h"

@interface SettingsViewController : SettingsBaseViewController<MFMailComposeViewControllerDelegate, PopoverDelegate>

@property (weak, nonatomic) IBOutlet UILabel * versionLbl;
@property (weak, nonatomic) IBOutlet UIView * settingContainerView;
@property (weak, nonatomic) IBOutlet UIView * viewBg;

@property (strong, nonatomic) UIPopoverController * languagesPopover;
@property (strong, nonatomic) UIPopoverController * countryPopover;
@property (nonatomic, weak) ProfileViewController* vc;

-(IBAction)closeSettings:(id)sender;
-(void)startBgAnimation;

@end
