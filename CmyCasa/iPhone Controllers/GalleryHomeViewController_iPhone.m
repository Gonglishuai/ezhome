//
//  iphoneGalleryHomeViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/3/13.
//
//  Avihay 12/2/2014 - Modified loading of the background image
//  to take into account only the storyboard image rather then
//  from code.
//

#import "GalleryHomeViewController_iPhone.h"
#import "UserLoginViewController_iPhone.h"
#import "ProfileViewController.h"
#import "SHRNViewController.h"
#import "ProfileViewController_iPhone.h"

#import "ControllersFactory.h"
#import "UserManager.h"
#import "NotificationNames.h"

#import <FLAnimatedImage/FLAnimatedImage.h>

#import "NSString+Contains.h"
#import "UIImageView+ViewMasking.h"
#import "UIView+Alignment.h"

#define HOME_NEW_DESIGN NSLocalizedString(@"create_new_design", @"")
#define HOME_DESIGN_STREAM NSLocalizedString(@"3d_design_stream", @"")
#define HOME_CATALOG NSLocalizedString(@"catalog", @"")

@interface GalleryHomeViewController_iPhone ()
{
}

@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *btnNewDesign;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *btn3DStream;
@property (weak, nonatomic) IBOutlet HSNUIIconLabelButton *btnCatalog;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *arImage;
@property (weak, nonatomic) IBOutlet UIView *headerView;

- (IBAction)openProfileAction:(id)sender;

@end

@implementation GalleryHomeViewController_iPhone
{
    BOOL isFirstLoading;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoading = YES;

    self.backgroundImage.alpha=1.0;
    
    [self.ivProfileImage setMaskToCircleWithBorderWidth:1.5f andColor:[UIColor whiteColor]];

    [self.btn3DStream setTitle:HOME_DESIGN_STREAM forState:UIControlStateNormal];
    [self.btnNewDesign setTitle:HOME_NEW_DESIGN forState:UIControlStateNormal];
    [self.btnCatalog setTitle:HOME_CATALOG forState:UIControlStateNormal];
    if (ARConfiguration.isSupported) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"LABELgg" withExtension:@"gif"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.arImage.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
        self.arImage.hidden = NO;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([ConfigManager deviceTypeisIPhoneX]) {
        [UIView getIphoneXoffsetcurrentView:self.headerView andControllerView:self.view.bounds andDirection:DirectionTop andMargin:8];
        [UIView getIphoneXoffsetcurrentView:self.logoImage andControllerView:self.view.bounds andDirection:DirectionBottom andMargin:6];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
    
    // set animated label only for the first load
    if (isFirstLoading == YES)
    {
        self.shineLabel = [[RQShineLabel alloc] initWithFrame:CGRectMake(0, 0, 220, 144)];
        self.shineLabel.numberOfLines = 3;
        self.shineLabel.attributedText = [ConfigManager getWelcomeAtributeString];
        self.shineLabel.font = [UIFont fontWithName:@".SFUIText-Light" size:34.0];
        [self.shineLabel sizeToFit];
        [self.animatedLabelContainerView addSubview:self.shineLabel];
        
        [self.shineLabel shine];
        
        isFirstLoading = NO;
        
        // animate main screen options menu
        [self performSelector:@selector(animateGalleryMenuOptions:) withObject:_galleryMenuOptionsView afterDelay:0.5];
    }
    else
    {
        //set animated label location
        [self.shineLabel setFrame:CGRectMake(0, 0, self.shineLabel.frame.size.width, self.shineLabel.frame.size.height)];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc -  GalleryHomeViewController_iPhone");
}

#pragma mark - Overrides
-(void)updateProfileDetails
{
    [super updateProfileDetails];
    
    if ([[UserManager sharedInstance] isLoggedIn])
    {
        [self loadProfileImage:[[[UserManager sharedInstance] currentUser]userProfileImage]];
    }
    else
    {
        [self.ivProfileImage setImage:[UIImage imageNamed:@"user_avatar_notlogin"]];
    }
}

-(void)loadProfileImage:(NSString*)profileImage{
    
    if (!profileImage || [profileImage length] == 0) {
        [self.ivProfileImage setImage:[UIImage imageNamed:@"user_avatar"]];
        return;
    }
    
    [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.ivProfileImage url:profileImage];
}

- (IBAction)openMenuAction:(id)sender {
    [[UIMenuManager sharedInstance] openMenu:self];
}

- (IBAction)openProfileAction:(id)sender
{
    [super openProfileAction:sender];
    
    if (![[UserManager sharedInstance] isLoggedIn])
    {
        //If we are in the process of silent login, do nothing and wait for the process to end
        if ([[UserManager sharedInstance] isSilenceLoggInProcess]) {
            return;
        }
        
        //Send infromation from wher log in poped up
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
        
        if ([ConfigManager isSignInSSOActive]) {
            
            SHRNViewController *ulController = [[SHRNViewController alloc] init];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:ulController];
            [self presentViewController:navc animated:NO completion:nil];
//            
//            [MGJRouter openURL:@"/UserCenter/LogIn"];
            
        }else if ([ConfigManager isSignInWebViewActive]) {
            GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
            [self presentViewController:web animated:NO completion:nil];
        }else{
            UINavigationController * navbar = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
            
            UserLoginViewController_iPhone * viewop = [[navbar viewControllers] objectAtIndex:0];
            
            viewop.openingType=eModal;
            viewop.eventLoadOrigin=EVENT_PARAM_LOAD_ORIGIN_MENU;
            [self presentViewController:navbar animated:NO completion:nil];
        }
    }
    else
    {
        ProfileViewController *profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];

        UserDO *currentUser = [[UserManager sharedInstance] currentUser];
        UserProfile *userProfile = [[UserProfile alloc] init];
        userProfile.userId = currentUser.userID;
        userProfile.firstName = currentUser.firstName;
        userProfile.lastName = currentUser.lastName;
        userProfile.userPhoto = currentUser.userProfileImage;
        userProfile.userDescription = currentUser.userDescription;

        profileViewController.userId = currentUser.userID;
        profileViewController.userProfile = userProfile;

        [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:NO];
        [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
        
        [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeLoginOrProfile];
    }
}

- (IBAction)actionStartNewDesign:(id)sender {
    //mark iphone menu new design selection
    [[[UIMenuManager sharedInstance] menuViewController] setMenuButtonSelection:kMenuOptionTypeNewDesigns];
    [[UIMenuManager sharedInstance] newDesignPressedIphone];
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:@"home_screen", nil];
        NSArray * keys=[NSArray arrayWithObjects:@"action_source" ,nil];
//        [HSFlurry logEvent:FLURRY_NEW_DESIGN_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

- (IBAction)action3DStreamSelected:(id)sender {
    [super action3DStreamSelected:sender];
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        
        NSArray * objs=[NSArray arrayWithObjects:@"3d",@"home_screen", nil];
        NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
        
//        [HSFlurry logEvent:FLURRY_3DDESIGN_HOME_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        
    }
#endif
    //mark iphone menu new design selection
    [[[UIMenuManager sharedInstance] menuViewController] setMenuButtonSelection:kMenuOptionTypeDesignStream3D];
    [[UIMenuManager sharedInstance] setIsUserChangedFilter:NO];
    [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D
                                                 andRoomType:@""
                                                   andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType3D]];
}

- (IBAction)actionCatalogSelected:(id)sender {
    
    [super actionCatalogSelected:sender];
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_CATALOG withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_HOME_SCREEN}];
    
    [[UIManager sharedInstance] openHomeCatalog];
    
    //mark iphone menu new design selection
    [[[UIMenuManager sharedInstance] menuViewController] setMenuButtonSelection:kMenuOptionTypeCatalog];
}

- (IBAction)actionHelpSelected:(id)sender {
    
    [[UIManager sharedInstance] openHelpArticle];
}

#pragma mark -
- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
	return UIInterfaceOrientationMaskPortrait| UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)gotoSJJ:(id)sender {
    AppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
    [delegate gotoSJJ];
}



@end
