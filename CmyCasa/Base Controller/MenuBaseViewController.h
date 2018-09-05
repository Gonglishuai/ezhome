//
//  MenuBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/18/13.
//
//

#import <UIKit/UIKit.h>
#import "UIManager.h"


@class ProtocolsDef;
@class MessageUI;
@class MFMailComposeViewController;

static NSString * MENU_OPTION_PROFILE = @"menu_profile";
static NSString * MENU_OPTION_3DDESIGN= @"menu_3d_design";
static NSString * MENU_OPTION_2DDESIGN = @"menu_2d_design";
static NSString * MENU_OPTION_ARTICLE = @"menu_article";
static NSString * MENU_OPTION_CATALOG = @"menu_catalog";
static NSString * MENU_OPTION_PROFESSIONAL = @"menu_professional";
static NSString * MENU_OPTION_NEW_DESIGN = @"menu_new_design";
static NSString * MENU_OPTION_HELP = @"menu_help";

//GAITrackedViewController
@interface MenuBaseViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)myHome:(id)sender;
- (IBAction)newDesignPressed:(id)sender;
- (IBAction)designStream3DPressed:(id)sender;
- (IBAction)catalogPressed:(id)sender;
- (IBAction)mySettingPressed:(id)sender;
- (IBAction)openProfilePagePressed:(id)sender;
- (IBAction)openFeedbackAction:(id)sender;
- (void)designStream2DPressed:(id)sender;
- (void)designStreamArticlePressed:(id)sender ;
- (void)professionalsPressed:(id)sender;
- (void)setMenuButtonSelection:(NSInteger)menuIndex;
- (void)updateEditProfileMenu;
- (void)actionEmailComposer;
- (void)refreshPanelButtonsState;
- (void)wlMagazinePressed:(id)sender;

@property( nonatomic) BOOL isInDesign;
@property( nonatomic) NSString * delayedAction;
@property (weak, nonatomic) IBOutlet UIView *menuViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *userLoginButton;
@property (weak, nonatomic) IBOutlet UILabel *userLoginLabel;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *myhomestylerButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *designStream3DButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *catalogButton;
@property (weak, nonatomic) HSNUIIconLabelButton *designStream2DButton;
@property (weak, nonatomic) HSNUIIconLabelButton *designStreamArticleButton;
@property (weak, nonatomic) HSNUIIconLabelButton *profButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *feedbackButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *nDesignButton;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView * settingsContainer;
@end
