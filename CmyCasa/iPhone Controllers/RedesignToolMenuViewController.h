//
//  RedesignToolMenuViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import <UIKit/UIKit.h>
#define MENU_CLOSED_POSITION 0
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class MainViewController;
@interface RedesignToolMenuViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *internalControlsView;
@property (weak, nonatomic) MainViewController * mainVc;
@property (weak, nonatomic) IBOutlet UIButton  *toolMainMenuButton;
@property (weak, nonatomic) IBOutlet UIView *toolMainMenuButtonView;
@property (weak, nonatomic) IBOutlet UIButton  *paintButton;


- (IBAction)backPressed:(id)sender;
- (IBAction)sharePressed:(id)sender;
- (IBAction)paintPressed:(id)sender;
- (IBAction)deletePressed:(id)sender;
- (IBAction)savePressed:(id)sender;
- (IBAction)scalePressed:(id)sender;
- (IBAction)toggleDesignMenu:(id)sender;
- (IBAction)imageOptionsPressed:(id)sender;
- (void)forceClosingMenu;
- (void)hideMenuButton;
- (void)showMenuButton;

@end
