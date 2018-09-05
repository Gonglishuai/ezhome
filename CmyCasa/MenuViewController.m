//
//  MenuViewController.h.m
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import "MenuViewController.h"
#import "MainViewController.h"
#import "ControllersFactory.h"
#import "NotificationNames.h"
#import "UIImageView+ViewMasking.h"
#import "UIButton+NUI.h"
#import "ConfigManager.h"
#import "UIView+ReloadUI.h"
#import "NSString+Contains.h"
#import "SHRNViewController.h"

@implementation MenuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);

        self.view.frame = CGRectMake(0, 0, 1024, 768);
        
        self.menuViewContainer.frame = CGRectMake(0, -500, self.menuViewContainer.frame.size.width,
                                                  self.menuViewContainer.frame.size.height);
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{ self.menuViewContainer.frame = CGRectMake(0, 0, 1024, 768);}
                         completion:nil];

    } else {
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = CGRectMake(0, 0, 1024, 768);
        
       
        [self.profileImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];

        self.menuViewContainer.frame = CGRectMake(-500, 0, self.menuViewContainer.frame.size.width,
                                                      self.menuViewContainer.frame.size.height);
        
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.menuViewContainer.frame = CGRectMake(0, 0, self.menuViewContainer.frame.size.width,self.menuViewContainer.frame.size.height);

        } completion:^(BOOL finished) {
            
        }];
    }
    
    [self.view reloadUI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateDynamicMenu];
}

-(void)dealloc{
    NSLog(@"dealloc - MenuViewController");
}


#pragma mark - Class Functions

-(void)generateDynamicMenu{
    //order in the array is important!!!
    NSArray * menuOption = [NSArray arrayWithObjects:
                            [NSNumber numberWithBool:[ConfigManager is3DGalleryActive]],
                            [NSNumber numberWithBool:[ConfigManager is2DGalleryActive]],
                            [NSNumber numberWithBool:[ConfigManager isMagazineActive]],
                            [NSNumber numberWithBool:[ConfigManager isProfessionalIndexActive]],
                            [NSNumber numberWithBool:[ConfigManager isWLMagazineActive]],nil];
    
    NSUInteger menuOriginY = self.catalogButton.frame.origin.y + self.catalogButton.frame.size.height;
    NSUInteger btnHeight = self.catalogButton.frame.size.height;
    NSUInteger btnWidth = self.catalogButton.frame.size.width;
    NSUInteger totalDynamicMenuHeight = 0;
    HSNUIIconLabelButton * btnCurrent = nil;
    
    if (menuOption && [menuOption count] > 0) {
        for (int i = 0; i < [menuOption count]; i++) {
            if ([[menuOption objectAtIndex:i] boolValue]) {
                btnCurrent = [HSNUIIconLabelButton buttonWithType:UIButtonTypeCustom];
                [btnCurrent setFrame:CGRectMake(0, menuOriginY + totalDynamicMenuHeight, btnWidth, btnHeight)];
                [btnCurrent setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                UIEdgeInsets contetntInsets = UIEdgeInsetsMake(0.0, 63.0, 0.0, 0.0);
                [btnCurrent setContentEdgeInsets:contetntInsets];
                switch (i) {
                    case 0:{
                        [btnCurrent addTarget:self action:@selector(designStream3DPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"3d_design_stream", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"General_MenusButtonSelectionBackground:GalleryMenu_GeneralMenuButton";
                        btnCurrent.iconNuiClass = @"GalleryMenu_3DDesignStreamIcon:General_MenusIcon";
                        btnCurrent.iconDefaultHexValue = @"";
                        btnCurrent.offlineHidden = YES;
                        [btnCurrent setAccessibilityLabel:@"btn_menuCatalog"];
                        break;
                    }
                    case 1:{
                        [btnCurrent addTarget:self action:@selector(designStream2DPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_photo_gallery", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_PhotoGalleryIcon";
                        btnCurrent.iconDefaultHexValue = @"";
                        btnCurrent.offlineHidden = YES;
                        [btnCurrent setAccessibilityLabel:@"btn_photo_gallery"];
                        break;
                    }
                    case 2:{
                        [btnCurrent addTarget:self action:@selector(designStreamArticlePressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_homestyler_magazine", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:General_MenusIcon:GalleryMenu_HomestylerMagazineIcon";
                        btnCurrent.iconDefaultHexValue = @"";
                        btnCurrent.offlineHidden = YES;
                        [btnCurrent setAccessibilityLabel:@"btn_magazine"];
                        break;
                    }
                    case 3:{
                        [btnCurrent addTarget:self action:@selector(professionalsPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_prof_index", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_ProfessionalIndexIcon";
                        btnCurrent.iconDefaultHexValue = @"";
                        btnCurrent.offlineHidden = YES;
                        [btnCurrent setAccessibilityLabel:@"btn_prof_index"];
                        break;
                    }
                    case 4:{
                        
                        NSString * customTitle = [NSString localizedStringCustom:@"dynamic_menu_wl_magazine"];
                        
                        [btnCurrent addTarget:self
                                       action:@selector(wlMagazinePressed:)
                             forControlEvents:UIControlEventTouchUpInside];
                        
                        [btnCurrent setTitle:customTitle
                                    forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"General_MenusButtonSelectionBackground:GalleryMenu_GeneralMenuButton";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_HomestylerMagazineIcon";
                        btnCurrent.iconDefaultHexValue = @"";
                        btnCurrent.offlineHidden = YES;
                        [btnCurrent setAccessibilityLabel:@"btn_magazine"];
                        break;
                    }
                    default:
                        break;
                }
                         
                [btnCurrent addIconButton];
                [self.menuViewContainer addSubview:btnCurrent];
                totalDynamicMenuHeight += (btnHeight + 3);
            }
        }
        
        //add setting container
        [self.settingsContainer setFrame:CGRectMake(0, menuOriginY + totalDynamicMenuHeight, self.settingsContainer.frame.size.width, self.settingsContainer.frame.size.height)];
        [self.menuViewContainer addSubview:self.settingsContainer];
    }
}

-(void)loadProfileImage:(NSString*)profileImage{
    
    if (profileImage==nil || [profileImage length]==0) {
        if (IS_IPAD) {
            [self.profileImage setImage:[UIImage imageNamed:@"iph_profile_settings_image.png"]];
        }else{
            
            [self.profileImage setImage:[UIImage imageNamed:@"iph_profile_image.png"]];
        }
        return;
    }
    
    [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.profileImage url:profileImage];
}

-(void)setProfileImageFrame:(NSString*)path{
    
    UIImage * img = [UIImage safeImageWithContentsOfFile:path];
    if(img){
        [self.profileImage setImage:img];
        
        CGRect frm = self.profileImage.frame;
        frm.size = IS_IPAD ? CGSizeMake(52, 52) : CGSizeMake(35, 34);
        self.profileImage.frame = frm;
    }
}

-(int)getIndexOfSelectedMenuButton{
    
    
    if (self.userLoginButton.selected) {
        return 0;
    }
    
    if (self.nDesignButton.selected) {
        return 1;
    }
    if (self.designStream3DButton.selected) {
        return 2;
    }
    if (self.designStream2DButton.selected) {
        return 3;
    }
    
    if (self.designStreamArticleButton.selected) {
        return 4;
    }
    if (self.profButton.selected) {
        return 5;
    }
    if (self.feedbackButton.selected) {
        return 6;
    }
    if (self.settingsButton.selected) {
        return 7;
    }
    
    return 0;
}

- (IBAction)newDesignPressed:(id)sender {
    [super newDesignPressed:sender];
    
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    if (self.isInDesign) {
       [self.view setHidden:YES];
         self.delayedAction = MENU_OPTION_NEW_DESIGN;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [self.view setHidden:YES];
    
    if(self.parentViewController != nil &&
       [self.parentViewController isKindOfClass:[MainViewController class]] &&
       [self.delayedAction isEqualToString:MENU_OPTION_NEW_DESIGN])
    {
        [[UIMenuManager sharedInstance] newDesignPressed:[[[[UIManager sharedInstance] pushDelegate] navigationController]topViewController]];
        return;
    }
    
    [[UIMenuManager sharedInstance] newDesignPressed:self.parentViewController];
}

/****************************************************************************************************************************************/
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

- (IBAction)designStream3DPressed:(id)sender {
    [super designStream3DPressed:sender];
    
    if (self.isInDesign) {
        [self.view setHidden:YES];
        self.delayedAction = MENU_OPTION_3DDESIGN;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [self.view setHidden:YES];
    [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D
                                                 andRoomType:@""
                                                   andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType3D]];
}

- (void)designStream2DPressed:(id)sender {
    [super designStream2DPressed:sender];
    
    [self.view setHidden:YES];

    if (self.isInDesign) {
          self.delayedAction = MENU_OPTION_2DDESIGN;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
            
    [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType2D
                                                 andRoomType:@""
                                                   andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType2D]];
}

-(void)designStreamArticlePressed:(id)sender{
    
    [super designStreamArticlePressed:sender];

    if (self.isInDesign) {
        [self.view setHidden:YES];
        self.delayedAction = MENU_OPTION_ARTICLE;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [self.view setHidden:YES];
    
    [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamTypeArticles
                                                 andRoomType:@""
                                                   andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamTypeArticles]];
}

/****************************************************************************************************************************************/
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

- (IBAction)catalogPressed:(id)sender
{
    if (self.isInDesign) {
        [self.view setHidden:YES];
        [[UIManager sharedInstance] askMainViewControllerToOpenCatalog];
        return;
    }
    
    [super catalogPressed:sender];
    
    [self.view setHidden:YES];
    
    [[UIManager sharedInstance] openHomeCatalog];
}

- (IBAction)mySettingPressed:(id)sender {
    [super mySettingPressed:sender];
    
    [self.view setHidden:YES];
    
    [[UIMenuManager sharedInstance] openSettingsPressed:self.parentViewController];
}

- (IBAction)openProfilePagePressed:(id)sender {
    
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable])
        return;
    
    [super openProfilePagePressed:sender];
    
    if (self.isInDesign && [[UserManager sharedInstance] isLoggedIn]) {
        [self.view setHidden:YES];
        self.delayedAction=MENU_OPTION_PROFILE;
        
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }

    if (![[UserManager sharedInstance] isLoggedIn]) {
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//         @{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON,
//           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
        
        if ([ConfigManager isSignInSSOActive]) {
            SHRNViewController *ulController = [[SHRNViewController alloc] init];
            [self.parentViewController addChildViewController:ulController];
            [self.parentViewController.view addSubview:ulController.view];
        }else if ([ConfigManager isSignInWebViewActive]) {
            [ExternalLoginViewController showExternalLogin:self.parentViewController];
        }else{
            UserLoginViewController *
            userLoginViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
            userLoginViewController.userLogInDelegate = self;
            userLoginViewController.eventLoadOrigin = EVENT_PARAM_LOAD_ORIGIN_MENU;
            userLoginViewController.openingType = eView;
            [self.parentViewController addChildViewController:userLoginViewController];
            [self.parentViewController.view addSubview:userLoginViewController.view];
            userLoginViewController.view.frame = self.view.frame;
        }
        
        [self.view setHidden:YES];

        return;
    }
    
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeLoginOrProfile];
    
    [self.view setHidden:YES];
    [[UIMenuManager sharedInstance] myHomePressed:self.parentViewController];
}

- (void) loginRequestEndedwithState:(BOOL) state{
    //TODO: IMPLEMENT 2nd time action after state=yes login
}

- (IBAction)closeMenuOverlay:(id)sender {
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.menuViewContainer.frame = CGRectMake(-500, 0,self.menuViewContainer.frame.size.width,
                                                                   self.menuViewContainer.frame.size.height);
                         
                         
                     }
                     completion:^(BOOL finished){ [  self.view setHidden:YES]; }];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)openFeedbackAction:(id)sender {
    [super openFeedbackAction:sender];
    if (![ConfigManager isAnyNetworkAvailable]) {
        return;
    }
   
    [self closeMenuOverlay:nil];
}

- (IBAction)myHome:(id)sender
{
    if (self.isInDesign) {
        [self.view setHidden:YES];
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [super myHome:sender];
    
    [self closeMenuOverlay:nil];
}

#pragma mark-
#pragma mark Handled By Base Class

- (IBAction)professionalsPressed:(id)sender {
    [super professionalsPressed:sender];
      
    if (self.isInDesign) {
        [self.view setHidden:YES];
         self.delayedAction=MENU_OPTION_PROFESSIONAL;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [self.view setHidden:YES];
    [[UIMenuManager sharedInstance] professionalsPressed:self.parentViewController];
}


@end
