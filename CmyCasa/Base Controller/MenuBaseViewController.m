//
//  MenuBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/18/13.
//
//

#import "MenuBaseViewController.h"
#import "ProtocolsDef.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NotificationNames.h"
#import "UIView+ReloadUI.h"
#import <sys/utsname.h>
#import "ImageFetcher.h"

@interface MenuBaseViewController ()

@end

@implementation MenuBaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(designSaveOnExitNotification:)
                                                 name:@"designSaveOnExitNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateEditProfileMenu)
                                                 name:kNotificationUserDidLoginSuccessfully
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged"
                                               object:nil];
    if ([ConfigManager isWhiteLabel]) {
        [self.myhomestylerButton setTitle:NSLocalizedString(@"my_homestyler_menu_wl", @"") forState:UIControlStateNormal];
    }
    
    [self updateEditProfileMenu];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"designSaveOnExitNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUserDidLoginSuccessfully object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.view name:@"NetworkStatusChanged" object:nil];

    [super viewWillDisappear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)dealloc{
    NSLog(@"dealloc - MenuBaseViewController");
}

#pragma mark -

-(void)updateEditProfileMenu{
    if ([[UserManager sharedInstance] isLoggedIn]) {
        NSString * fullname = [[[UserManager sharedInstance] currentUser] getUserFullName];
        
        if ([fullname length] == 0) {
            fullname = NSLocalizedString(@"edit_profile", @"Edit Profile");
        }
        
        [self.userLoginLabel setText:fullname];
        [self loadProfileImage:[[[UserManager sharedInstance] currentUser] userProfileImage]];
    }else{
        [self.userLoginLabel setText:NSLocalizedString(@"sign_in", @"Sign In") ];
        [self loadProfileImage:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshPanelButtonsState
{
    if ([ConfigManager isOfflineModeActive])
        return;
    
    
    if([[UserManager sharedInstance] isSilenceLoggInProcess])
    {
        self.myhomestylerButton.enabled = NO;
        self.userLoginButton.enabled = NO;
        self.userLoginLabel.enabled = NO;
    }
    else
    {
        self.myhomestylerButton.enabled = YES;
        self.userLoginButton.enabled = YES;
        self.userLoginLabel.enabled = YES;
    }
}

-(void)designSaveOnExitNotification:(NSNotification*)notification{
    
    if (self.delayedAction) {
        self.isInDesign=NO;
        //perform menu selection
        if ([self.delayedAction isEqualToString:MENU_OPTION_PROFILE]) {
            [self openProfilePagePressed:self];
        }
        if ([self.delayedAction isEqualToString:MENU_OPTION_NEW_DESIGN]) {
            
            [self newDesignPressed:self];
        }
        
        if ([self.delayedAction isEqualToString:MENU_OPTION_2DDESIGN]) {
            [self designStream2DPressed:self];
        }
        if ([self.delayedAction isEqualToString:MENU_OPTION_3DDESIGN]) {
            [self designStream3DPressed:self];
        }
        if ([self.delayedAction isEqualToString:MENU_OPTION_ARTICLE]) {
            [self designStreamArticlePressed:self];
        }

        if ([self.delayedAction isEqualToString:MENU_OPTION_PROFESSIONAL]) {
            [self professionalsPressed:self];
        }
        if ([self.delayedAction isEqualToString:MENU_OPTION_CATALOG]) {
            [self catalogPressed:self];
        }
        
        self.delayedAction=nil;
    }
}

- (void)unSelectAndUnHighlight:(UIButton*)button
{
    [button setSelected:NO];
    [button setHighlighted:NO];
}

-(void)setMenuButtonSelection:(NSInteger)menuIndex
{
    NSArray *buttons = @[self.userLoginButton,
                         self.feedbackButton,
                         self.nDesignButton,
                         self.settingsButton,
                         self.myhomestylerButton,
                         self.catalogButton];
    
    for (UIButton *menuButton in buttons)
    {
        [self unSelectAndUnHighlight:menuButton];
    }
   
    switch (menuIndex) {
        case kMenuOptionTypeLoginOrProfile:
        {
            [self.userLoginButton setSelected:YES];
            [self.myhomestylerButton setSelected:YES];
        }
            break;
        case kMenuOptionTypeNewDesigns:
            [self.nDesignButton setSelected:YES];
            break;
        case kMenuOptionTypeDesignStream3D:
            [self.designStream3DButton setSelected:YES];
            break;
        case kMenuOptionTypeCatalog:
            [self.catalogButton setSelected:YES];
            break;
        case kMenuOptionTypeDesignStream2D:
            [self.designStream2DButton setSelected:YES];
            break;
        case kMenuOptionTypeDesignStreamArticle:
            [self.designStreamArticleButton setSelected:YES];
            break;
        case kMenuOptionTypeProfessionalIndex:
            [self.profButton setSelected:YES];
            break;
        case kMenuOptionTypeFeedback:
            [self.feedbackButton setSelected:YES];
            break;
        case kMenuOptionTypeSettings:
            [self.settingsButton setSelected:YES];
            break;
        default:
            break;
    }
}



- (IBAction)professionalsPressed:(id)sender {
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
        
//            [HSFlurry logEvent: FLURRY_PROFS_MENU_CLICK];
        
    }
#endif
    
    
    
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeProfessionalIndex];
    
}


- (IBAction)designStream3DPressed:(id)sender {
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
            NSArray * objs=[NSArray arrayWithObjects:@"3d",@"main_menu", nil];
            NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
//            [HSFlurry logEvent:FLURRY_3DDESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

-(IBAction)designStreamArticlePressed:(id)sender{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
            NSArray * objs=[NSArray arrayWithObjects:@"article",@"main_menu", nil];
            NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
            
//            [HSFlurry logEvent:FLURRY_3DDESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif

}

- (IBAction)designStream2DPressed:(id)sender {
    if (self.isInDesign) {
        self.delayedAction=MENU_OPTION_2DDESIGN;
        return;
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
            NSArray * objs=[NSArray arrayWithObjects:@"2d",@"main_menu", nil];
            NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
            
//            [HSFlurry logEvent:FLURRY_3DDESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

- (IBAction)catalogPressed:(id)sender
{
    if (self.isInDesign) {
        self.delayedAction=MENU_OPTION_CATALOG;
        return;
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:@"cat",@"main_menu", nil];
        NSArray * keys=[NSArray arrayWithObjects:@"filter_stream",@"action_source" ,nil];
        
//        [HSFlurry logEvent:FLURRY_3DDESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

- (IBAction)mySettingPressed:(id)sender{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent: FLURRY_SETTING_MENU_CLICK];
    }
#endif
    if (!IS_IPAD) {
        [self setMenuButtonSelection:kMenuOptionTypeSettings];
    }
}

- (IBAction)openFeedbackAction:(id)sender{
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        
//            [HSFlurry logEvent: FLURRY_FEEDBACK_MENU_CLICK];
    }
#endif
    
    [self actionEmailComposer];
}

- (IBAction)openProfilePagePressed:(id)sender {
   
    if (![[UserManager sharedInstance] isLoggedIn]) {
//       [HSFlurry logAnalyticEvent:PARAM_NAME_SIGN_IN_MAIN_MENU];
    }
}

- (void)actionEmailComposer {
    NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
    NSString * subject;

        if(dict!=NULL){
            subject= NSLocalizedString(@"feedback_email_subject",@"Share with Homestyler Team");
            NSString * body;
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            struct utsname systemInfo;
            uname(&systemInfo);
            
            NSString * dd =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            NSString *osversion=[UIDevice currentDevice].systemVersion;
            body=[NSString stringWithFormat:@"\n\n\n----------------------------------------\nHomestyler version: %@-%@\n Device: %@\nVersion: %@",version,build,dd,osversion];
            [[UIMenuManager sharedInstance] createEmailWithTitle:subject
                                                         andBody:body
                                             forPresentingTarget:self
                                                  withRecipients:[NSArray arrayWithObject:[[dict objectForKey:@"feedback"] objectForKey:@"toaddress"]] ];
        }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    

    [self dismissViewControllerAnimated:YES completion:nil];
    if(result	!=	MFMailComposeResultCancelled)
    {
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent: FLURRY_FEEDBACK_MAIL_SENT];
        }
#endif
        
    }
}

-(void)loadProfileImage:(NSString*)profileImage{
    
    if (!profileImage || [profileImage length] == 0) {
        [self.profileImage setImage:[UIImage imageNamed:@"user_avatar"]];
        return;
    }
    
    [[GalleryServerUtils sharedInstance] loadImageFromUrl:self.profileImage url:profileImage];
}

- (IBAction)myHome:(id)sender
{
    [[UIMenuManager sharedInstance] applicationHomePressed:sender];
    [self setMenuButtonSelection:kMenuOptionTypeHome];
}

- (IBAction)newDesignPressed:(id)sender
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSArray * objs=[NSArray arrayWithObjects:@"main_menu", nil];
        NSArray * keys=[NSArray arrayWithObjects:@"action_source" ,nil];
        
//        [HSFlurry logEvent:FLURRY_NEW_DESIGN_MENU_CLICK withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
    }
#endif
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    self.screenName=GA_HOME_SCREEN;
}

- (void)wlMagazinePressed:(id)sender {
    NSString * url = [[ConfigManager sharedInstance] getWLMagazineURL];
    GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:url];
    [self.parentViewController presentViewController:web animated:YES completion:nil];
}

@end
