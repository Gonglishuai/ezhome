//
//  GalleryHomeViewController.m
//  CmyCasa
//
//  Created by Gil Hadas.
//
//
// Avihay June 9th: Added support for the following feature:
// Whenever a user will open the application for the third time without being
// logged-in, the log in screen shall appear

#import "GalleryHomeViewController.h"
#import "AppDelegate.h"
#import "UIMenuManager.h"
#import "ImageEffectsBaseViewController.h"
#import "ControllersFactory.h"
#import "LocationManager.h"
#import "NotificationNames.h"
#import "MenuOptionType.h"
#import "UIImageView+ViewMasking.h"
#import "NSString+Contains.h"
#import "ExternalLoginViewController.h"
#import "UserLoginViewController.h"
#import "SHRNViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

#ifdef SERVER_RENDERING
#import "ServerRendererManager.h"
#endif

@interface GalleryHomeViewController ()
{
    BOOL isFirstLoad;
}
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *arImageIPad;

- (IBAction)openProfileAction:(id)sender;

@end

@implementation GalleryHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set flag and menu view for first loading animation
    isFirstLoad = YES;
    _galleryMenuOptionsView.alpha = 0;
    
    //QA Compatibility Labels:
    self.view.accessibilityLabel = @"Main Page";
    
    [self.ivProfileImage setMaskToCircleWithBorderWidth:1.5f andColor:[UIColor whiteColor]];

#ifdef SERVER_RENDERING
    [[ServerRendererManager sharedInstance] beginRenderingPulling];
#endif
    
    // set animated label only for the first load
    if (isFirstLoad == YES)
    {
        self.shineLabel = [[RQShineLabel alloc] initWithFrame:CGRectMake(0, 0, 430, 220)];
        self.shineLabel.numberOfLines = 3;
        self.shineLabel.attributedText = [ConfigManager getWelcomeAtributeString];
        self.shineLabel.font = [UIFont fontWithName:@".SFUIText-Light" size:67.0];
        [self.shineLabel sizeToFit];
        [self.animatedLabelContainerView addSubview:self.shineLabel];
    }
    if (ARConfiguration.isSupported) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"LABELgg" withExtension:@"gif"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.arImageIPad.animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance]updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //animate menu options on first load only
    if (isFirstLoad == YES)
    {
        isFirstLoad = NO;
        
        [self.shineLabel shine];
        
        // animate main screen options menu
        [self performSelector:@selector(animateGalleryMenuOptions:) withObject:_galleryMenuOptionsView afterDelay:0.1];
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc {
    NSLog(@"dealloc - GalleryHomeViewController");
}

#pragma mark - class function
- (IBAction)openMenuAction:(id)sender {
    [[UIMenuManager sharedInstance] openMenu:self]; 
}

- (IBAction)openProfileAction:(id)sender
{
    [super openProfileAction:sender];
    
    if (![[UserManager sharedInstance] isLoggedIn])
    {
        //If we are in the process of silent login, do nothing and wait for the process to end
        if ([[UserManager sharedInstance] isSilenceLoggInProcess])
            return;
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//         @{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON,
//           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
    
        if ([ConfigManager isSignInSSOActive]) {
            SHRNViewController *ulController = [[SHRNViewController alloc] init];
            [self.navigationController pushViewController:ulController animated:NO];
        }else if ([ConfigManager isSignInWebViewActive]) {
            [ExternalLoginViewController showExternalLogin:self];
        }else{
            UserLoginViewController *
            userLoginViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
            userLoginViewController.userLogInDelegate = nil;
            userLoginViewController.eventLoadOrigin = EVENT_PARAM_LOAD_ORIGIN_MENU;
            userLoginViewController.openingType = ePush;
            [userLoginViewController.view setFrame:self.view.frame];
            
            [self.navigationController pushViewController:userLoginViewController animated:NO];
        }
        return;
    }
    
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeLoginOrProfile];
    [[UIMenuManager sharedInstance] myHomePressed:self.parentViewController];
}

- (IBAction)actionStartNewDesign:(id)sender {
    //[HSFlurry logAnalyticEvent:@"start new design"];
    
    [[UIMenuManager sharedInstance] newDesignPressed:self];
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
            NSArray * objs=[NSArray arrayWithObjects:@"home_screen", nil];
            NSArray * keys=[NSArray arrayWithObjects:@"action_source" ,nil];
            
//            [HSFlurry logEvent:FLURRY_NEW_DESIGN_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

- (IBAction)action3DStreamSelected:(id)sender {
    
    [super action3DStreamSelected:sender];
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
       
            NSArray * objs=[NSArray arrayWithObjects:@"3d",@"home_screen", nil];
            NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
            
//            [HSFlurry logEvent:FLURRY_3DDESIGN_HOME_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        
    }
#endif
    [[UIMenuManager sharedInstance] setIsUserChangedFilter:NO];
    [[UIMenuManager sharedInstance] openGalleryStreamWithType:DesignStreamType3D
                                                 andRoomType:@""
                                                   andSortBy:[[UIMenuManager sharedInstance] getSortTypeForDesignStreamType:DesignStreamType3D]];
}

- (IBAction)actionCatalogSelected:(id)sender {
    
    [super actionCatalogSelected:sender];
        
//    [HSFlurry logAnalyticEvent:EVENT_NAME_LOAD_CATALOG withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_HOME_SCREEN}];
    
    [[UIManager sharedInstance] openHomeCatalog];
}

- (IBAction)actionHelpSelected:(id)sender {
    [[UIManager sharedInstance] openHelpArticle];
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

- (IBAction)gotoSJJ:(id)sender {
    AppDelegate *delegate = (id)[UIApplication sharedApplication].delegate;
    [delegate gotoSJJ];
}

@end




