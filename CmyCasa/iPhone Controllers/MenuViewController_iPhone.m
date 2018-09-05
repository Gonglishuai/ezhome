//
//  MenuViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/18/13.
//
//

#import "MenuViewController_iPhone.h"
#import "UserLoginViewController_iPhone.h"
#import "ProfileViewController.h"
#import "ControllersFactory.h"
#import "UIManager.h"
#import "NSString+Contains.h"
#import "SHRNViewController.h"

#import "UIButton+NUI.h"
#import "UIImageView+ViewMasking.h"

#define GAP 3

@interface MenuViewController_iPhone ()
{
    NSDate *    _lastClickedTime;
    NSUInteger  _totalDynamicMenuHeight;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollviewIphoneMenuViewController;
@property (weak, nonatomic) IBOutlet UIView *uiviewMenuContentView;

- (void)openLoginScreen:(UIViewController *)parent loadOrigin:(NSString *)loadOriginEvent;

@end

@implementation MenuViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateDynamicMenu];
    
    _lastClickedTime = [NSDate date];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self adujstScreenSizeAccordingToDevice];
    
    [self.profileImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
    
    self.menuViewContainer.frame = CGRectMake(-500,
                                              0,
                                              self.menuViewContainer.frame.size.width,
                                              self.view.frame.size.height);
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.menuViewContainer.frame = CGRectMake(0,
                                                  0,
                                                  self.menuViewContainer.frame.size.width,
                                                  self.view.frame.size.height);
        
    } completion:nil];
    
    [self.view reloadUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"dealloc - MenuViewController_iPhone");
}

#pragma mark - Class Function
-(void)generateDynamicMenu
{
    //order in the array is important!!!
    NSArray * menuOption = [NSArray arrayWithObjects:
                            [NSNumber numberWithBool:[ConfigManager is3DGalleryActive]],
                            [NSNumber numberWithBool:[ConfigManager is2DGalleryActive]],
                            [NSNumber numberWithBool:[ConfigManager isMagazineActive]],
                            [NSNumber numberWithBool:[ConfigManager isProfessionalIndexActive]],
                            [NSNumber numberWithBool:[ConfigManager isWLMagazineActive]], nil];
    
    NSUInteger menuOriginY = self.catalogButton.frame.origin.y + self.catalogButton.frame.size.height + GAP;
    NSUInteger menuOriginX = self.catalogButton.frame.origin.x;
    NSUInteger btnHeight = self.catalogButton.frame.size.height;
    NSUInteger btnWidth = self.catalogButton.frame.size.width;
    _totalDynamicMenuHeight = 0;
    HSNUIIconLabelButton * btnCurrent = nil;
    
    if (menuOption && [menuOption count] > 0) {
        for (int i = 0; i < [menuOption count]; i++) {
            if ([[menuOption objectAtIndex:i] boolValue]) {
                btnCurrent = [HSNUIIconLabelButton buttonWithType:UIButtonTypeCustom];
                [btnCurrent setFrame:CGRectMake(menuOriginX, menuOriginY + _totalDynamicMenuHeight, btnWidth, btnHeight)];
                [btnCurrent setAutoresizesSubviews:YES];
                [btnCurrent setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                UIEdgeInsets contetntInsets = UIEdgeInsetsMake(0.0, 35.0, 0.0, 0.0);
                [btnCurrent setContentEdgeInsets:contetntInsets];
                switch (i) {
                    case 0:{
                        [btnCurrent addTarget:self action:@selector(designStream3DPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"3d_design_stream", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"General_MenusButtonSelectionBackground:GalleryMenu_GeneralMenuButton";
                        btnCurrent.iconNuiClass = @"GalleryMenu_3DDesignStreamIcon:General_MenusIcon";
                        btnCurrent.offlineHidden = YES;
                        btnCurrent.iconDefaultHexValue = @"";
                        break;
                    }
                    case 1:{
                        [btnCurrent addTarget:self action:@selector(designStream2DPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_photo_gallery", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_PhotoGalleryIcon";
                        btnCurrent.offlineHidden = YES;
                        btnCurrent.iconDefaultHexValue = @"";
                        break;
                    }
                    case 2:{
                        [btnCurrent addTarget:self action:@selector(designStreamArticlePressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_homestyler_magazine", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_HomestylerMagazineIcon";
                        btnCurrent.offlineHidden = YES;
                        btnCurrent.iconDefaultHexValue = @"";
                        break;
                    }
                    case 3: {
                        [btnCurrent addTarget:self action:@selector(professionalsPressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:NSLocalizedString(@"dynamic_menu_prof_index", @"") forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"GalleryMenu_GeneralMenuButton:General_MenusButtonSelectionBackground";
                        btnCurrent.iconNuiClass = @"General_MenusIcon:GalleryMenu_ProfessionalIndexIcon";
                        btnCurrent.offlineHidden = YES;
                        btnCurrent.iconDefaultHexValue = @"";
                        break;
                    }
                    case 4:{
                        [btnCurrent addTarget:self action:@selector(wlMagazinePressed:) forControlEvents:UIControlEventTouchUpInside];
                        [btnCurrent setTitle:[NSString localizedStringCustom:@"dynamic_menu_wl_magazine"] forState:UIControlStateNormal];
                        btnCurrent.nuiClass = @"General_MenusButtonSelectionBackground:GalleryMenu_GeneralMenuButton";
                        btnCurrent.iconNuiClass = @"GalleryMenu_CatalogIcon:General_MenusIcon";
                        btnCurrent.offlineHidden = YES;
                        btnCurrent.iconDefaultHexValue = @"";
                        break;
                    }
                        
                    default:
                        break;
                }
                [btnCurrent addIconButton];
                [self.scrollviewIphoneMenuViewController addSubview:btnCurrent];
                _totalDynamicMenuHeight += (btnHeight + GAP);
            }
        }
        
        //add setting container
        [self.settingsContainer setFrame:CGRectMake(menuOriginX,
                                                    menuOriginY + _totalDynamicMenuHeight,
                                                    self.settingsContainer.frame.size.width,
                                                    self.settingsContainer.frame.size.height)];
        
        _totalDynamicMenuHeight = self.settingsContainer.frame.origin.y + self.settingsContainer.frame.size.height;
    }
}

- (void)adujstScreenSizeAccordingToDevice
{
    self.scrollviewIphoneMenuViewController.contentSize = CGSizeMake(self.uiviewMenuContentView.frame.size.width, _totalDynamicMenuHeight);
    [self.menuViewContainer setFrame:CGRectMake(self.menuViewContainer.frame.origin.x, self.menuViewContainer.frame.origin.y, self.menuViewContainer.frame.size.width, _totalDynamicMenuHeight)];
}

- (IBAction)myHome:(id)sender
{
    [super myHome:sender];
    
    [self closeMenuOverlay:nil];
}

-(void)professionalsPressed:(id)sender{
    [super professionalsPressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        [[UIMenuManager sharedInstance] professionalsIphonePressed:self];
    }else{
        NSLog(@"Too quick!!!");
    }
}

/****************************************************************************************************************************************/
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

- (IBAction)designStream3DPressed:(id)sender {
    [super designStream3DPressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D
                                                     andRoomType:@""
                                                       andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType3D]];
    }else{
        NSLog(@"Too quick!!!");
    }
}

- (void)designStream2DPressed:(id)sender {
    [super designStream2DPressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType2D
                                                     andRoomType:@""
                                                       andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType2D]];
    }else{
        NSLog(@"Too quick!!!");
    }
}

- (void)designStreamArticlePressed:(id)sender {
    [super designStreamArticlePressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamTypeArticles
                                                     andRoomType:@""
                                                       andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamTypeArticles]];
    }else{
        NSLog(@"Too quick!!!");
    }
}

/****************************************************************************************************************************************/
/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

- (IBAction)catalogPressed:(id)sender {
    [super catalogPressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        [[UIManager sharedInstance] openHomeCatalog];
    }else{
        NSLog(@"Too quick!!!");
    }
    
    [self closeMenuOverlay:nil];
}

- (IBAction)mySettingPressed:(id)sender{
    [super mySettingPressed:sender];
    [[UIMenuManager sharedInstance] openSettingsIphone];
    [self closeMenuOverlay:nil];
}

-(IBAction)openFeedbackAction:(id)sender{
    [super openFeedbackAction:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
    }else{
        NSLog(@"Too quick!!!");
    }
    
    [self closeMenuOverlay:nil];
}

- (IBAction)openProfilePagePressed:(id)sender {
    
    if ([ConfigManager isOfflineModeActive] && ![ConfigManager isAnyNetworkAvailable])
        return;
    
    [super openProfilePagePressed:sender];
    if (![[UserManager sharedInstance] isLoggedIn])
    {
        //Send infromation from wher log in poped up
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
        [self openLoginScreen:self.parentViewController loadOrigin:EVENT_PARAM_LOAD_ORIGIN_MENU ];
    }else{
        [self closeMenuOverlay:nil];

        ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
        [profileViewController setUserId:[[[UserManager sharedInstance] currentUser] userID]];
        
        [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
        
                NSArray * viewControllers = [[[UIManager sharedInstance] pushDelegate].navigationController viewControllers];
        if ([viewControllers containsObject:profileViewController]) {
            [[[UIManager sharedInstance] pushDelegate].navigationController popToViewController:profileViewController animated:YES];
        }else{
            [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
        }
        
        [self setMenuButtonSelection:kMenuOptionTypeLoginOrProfile];
    }
}

- (void)openHomePage:(id)sender {
    
    if (self.isInDesign) {
        [self.view setHidden:YES];
        self.delayedAction = MENU_OPTION_PROFILE;
        [[UIManager sharedInstance] askMainViewControllerToClose];
        return;
    }
    
    [[UIMenuManager sharedInstance] returnToInitialPage];
}

- (void)openLoginScreen:(UIViewController *)parent loadOrigin:(NSString *)loadOriginEvent {
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    if ([ConfigManager isSignInSSOActive]) {
//        SHRNViewController *setMemberTypeController = [[SHRNViewController alloc] init];
//        [parent presentViewController:setMemberTypeController animated:NO completion:nil];
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }else if ([ConfigManager isSignInWebViewActive]) {
        GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
        [parent presentViewController:web animated:YES completion:nil];
    }else{
        [self closeMenuOverlay:nil];
        UINavigationController * navbar = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
        UserLoginViewController_iPhone * viewop = [[navbar viewControllers] objectAtIndex:0];
        
        viewop.openingType=eModal;
        viewop.eventLoadOrigin=loadOriginEvent;
        [parent presentViewController:navbar animated:YES completion:nil];
    }
}

- (IBAction)newDesignPressed:(id)sender {
    [super newDesignPressed:sender];
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:_lastClickedTime];
    
    if (!_lastClickedTime || seconds > 1) {
        _lastClickedTime = [NSDate date];
        
        [self setMenuButtonSelection:kMenuOptionTypeNewDesigns];
        [[UIMenuManager sharedInstance] newDesignPressedIphone];
    }else{
        NSLog(@"Too quick!!!");
    }
}

- (IBAction)closeMenuOverlay:(id)sender {
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.menuViewContainer.frame = CGRectMake(-500,
                                                                   0,
                                                                   self.menuViewContainer.frame.size.width,
                                                                   self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){ [  self.view setHidden:YES]; }];
}

@end
