//
//  UIMenuManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/28/13.
//
//

#import "UIMenuManager.h"
#import "ProtocolsDef.h"
#import "MainViewController.h"
#import "ProfIndexViewController.h"
#import "ResetPasswordViewController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "SettingsViewController_iPhone.h"
#import "NewDesignMainViewController_iPhone.h"
#import "UserLoginViewController_iPhone.h"
#import "ProfileViewController.h"
#import "ProfessionalPageViewController_iPhone.h"
#import "ProfIndexViewController_iPhone.h"
#import "ControllersFactory.h"
#import "SHRNViewController.h"
#import "GalleryStreamBaseController.h"

#import <sys/utsname.h>

@interface UIMenuManager ()
{
    NewDesignMainViewController_iPhone * _newDesignViewControllerIphone;
    NewDesignViewController * _newDesignViewController ;
    ResetPasswordViewController * _resetPasswordController;
    SettingsViewController * _settingsViewController;
    AboutViewController * _aboutViewController;
    AboutViewController * _termsViewController;
    NSString *_currentSortTypeFilter;
    NSInteger _selectedMenuOptionIndex;
}

@end

@implementation UIMenuManager

static UIMenuManager *sharedInstance = nil;


+ (UIMenuManager *)sharedInstance {
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[UIMenuManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        
        _isUserChangedFilter = NO;
        _currentSortTypeFilter = @"1";
        _selectedMenuOptionIndex = -1;
        
        //login notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:@"SinginFacebookCompleteNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"SinginFacebookFailedCompleteNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"SinginControllerCanceledWithoutAction" object:nil];
    }
    return self;
}

#pragma mark-
#pragma mark Menu Navigations
-(void)removeNewDesignViewController{
    if([[_newDesignViewController view] superview]!=nil)
    {
        [_newDesignViewController.view removeFromSuperview];
        [_newDesignViewController removeFromParentViewController];
    }
}

-(void)removeNewDesignViewControllerIPhone{
    if([[_newDesignViewControllerIphone view] superview]!=nil)
    {
        [_newDesignViewControllerIphone.view removeFromSuperview];
        [_newDesignViewControllerIphone removeFromParentViewController];
    }
}

- (void)updateMenuSelectionIndexAccordingToUserId:(NSString*)userId {
    
    //If the selected user is the current active one, the selected index should be "My Homestyler"
    if ([userId isEqualToString:[[UserManager sharedInstance]currentUser].userID]) {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeLoginOrProfile];
    }
    else {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
    }
}

- (NSInteger)getMenuOptionSelectedIndex {
    return _selectedMenuOptionIndex;
}

-(void)updateMenuOptionSelectionIndex:(NSInteger)index{
    
    _selectedMenuOptionIndex = index;
    [_menuViewController setMenuButtonSelection:_selectedMenuOptionIndex];
}

- (void) openMenu:(UIViewController *)parentView
{
    if([[_menuViewController view] superview]!=nil)
    {
        [_menuViewController removeFromParentViewController];
        [_menuViewController.view removeFromSuperview];
    }
    
    _menuViewController = (MenuViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryMenu" inStoryboard:kMainStoryBoard];

    [parentView addChildViewController:_menuViewController];
    [parentView.view addSubview:_menuViewController.view];
    
    [_menuViewController setMenuButtonSelection:_selectedMenuOptionIndex];
    
    _menuViewController.isInDesign = NO;
    
    if ([parentView isKindOfClass:[MainViewController class]]) {
        SavedDesign * design = [[DesignsManager sharedInstance] workingDesign];
        if (design ) {
            _menuViewController.isInDesign = YES;
        }
    }
    [self refreshMenu];
}

- (void)newDesignPressed:(UIViewController*)senderView{
    
    //check offline mode + check network
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]) {
        [self showAlert];
        return;
    }
    
    if ([[[DesignsManager sharedInstance] workingDesign] dirty]){
        //close
        [_menuViewController removeFromParentViewController];
        [_menuViewController.view removeFromSuperview];
    }
    
    if(_newDesignViewController == nil){
        _newDesignViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"NewDesignViewID" inStoryboard:kMainStoryBoard];
        
        _newDesignViewController.iPadGalleryDelegate = self;
        
        [senderView addChildViewController:_newDesignViewController];
//        [senderView.view addSubview:_newDesignViewController.view];
        
        [UIView transitionWithView:senderView.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ { [senderView.view addSubview:_newDesignViewController.view]; }
                        completion:nil];
    }else {
        
        if ([_newDesignViewController parentViewController] == senderView) {
            [_newDesignViewController.view removeFromSuperview];
            [_newDesignViewController removeFromParentViewController];
        }else{
            if([[_newDesignViewController view] superview]!=nil)
            {
                [_newDesignViewController.view removeFromSuperview];
                [_newDesignViewController removeFromParentViewController];
            }
            
            [senderView addChildViewController:_newDesignViewController];
//            [senderView.view addSubview:_newDesignViewController.view];
            [UIView transitionWithView:senderView.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^ { [senderView.view addSubview:_newDesignViewController.view]; }
                            completion:nil];
        }
    }
}

-(void)logoutWithUI{
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        
        return;
    }
}

-(void)openGalleryStreamWithType:(NSString*) itemType andRoomType:(NSString*) roomType andSortBy:(NSString*) sortBy
{
    GalleryStreamBaseController* retVal  = (GalleryStreamBaseController*)[[GalleryStreamManager sharedInstance] openDesignStreamWithType:itemType
                                                                                                                             andRoomType:roomType
                                                                                                                               andSortBy:sortBy];
        
    retVal.isStreamOfEmptyRooms = [itemType isEqualToString:DesignStreamTypeEmptyRooms];
 
    if([itemType isEqual:DesignStreamType3D])
    {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStream3D];
    }
    else if([itemType isEqual:DesignStreamType2D])
    {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStream2D];
    }
    else if([itemType isEqual:DesignStreamTypeArticles])
    {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeDesignStreamArticle];
    }
    else if([itemType isEqual:DesignStreamTypeEmptyRooms])
    {
        [self updateMenuOptionSelectionIndex:kMenuOptionTypeNewDesigns];
    }
    
    //only one level application!
    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:NO];
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:retVal animated:YES];
}

-(void ) closeModalViewsAndPushNewView :(UIViewController*) ctrlToCheck :(id)sender
{
    BOOL isPresentedView = [[UIManager sharedInstance] pushDelegate].navigationController.topViewController == ctrlToCheck;
    
    if (isPresentedView == NO )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
        });
        
        //if sender is not part of navigation, then it was modal view, dismiss it
        if ([[UIManager sharedInstance] pushDelegate].navigationController.topViewController!=sender) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [sender dismissViewControllerAnimated:NO completion:nil];
            });
        }
        
        UIViewController* mainCtrl = [[UIManager sharedInstance] mainViewController];
        if(mainCtrl.presentingViewController.presentedViewController == mainCtrl)
        {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [mainCtrl dismissViewControllerAnimated:NO completion:nil];
            });
        }
        
        UIViewController * cntr = [[UIManager sharedInstance] pushDelegate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cntr.navigationController pushViewController:ctrlToCheck animated:NO];
        });
        
    }
}

- (void) myHomePressed:(id)sender{
    
    ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];

    UserDO *currentUser = [[UserManager sharedInstance] currentUser];
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.userId = currentUser.userID;
    userProfile.firstName = currentUser.firstName;
    userProfile.lastName = currentUser.lastName;
    userProfile.userPhoto = currentUser.userProfileImage;
    userProfile.userDescription = currentUser.userDescription;

    profileViewController.userId = currentUser.userID;
    profileViewController.userProfile = userProfile;

    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
    
    BOOL isPresentedView = [[UIManager sharedInstance] pushDelegate].navigationController.topViewController != sender;
    if (isPresentedView) {
        [sender dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void)openProfilePageForsomeUser:(NSString*)userId
{
    ProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    profileViewController.isShowSystemIcon = YES;
    profileViewController.userId = userId;
    UserProfile *userProfile = [[UserProfile alloc] init];
    userProfile.userId = userId;
    profileViewController.userProfile = userProfile;
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
}

- (void)applicationHomePressed:(id)sender
{
    //in case we on redesign screen we need to dismiss the main vc first
    [[[UIManager sharedInstance] pushDelegate] dismissViewControllerAnimated:YES completion:nil];
    
    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
}

- (void) professionalsPressed:(id)sender{
    if (![ConfigManager isAnyNetworkAvailable]) {
        [self showAlert];
        return;
    }
    
    ProfIndexViewController * profIndexViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfIndexViewController" inStoryboard:kProfessionalsStoryboard];

    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profIndexViewController animated:YES];
    
    BOOL isPresentedView = [[UIManager sharedInstance] pushDelegate].navigationController.topViewController != sender;

    if (isPresentedView) {
        [sender dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void) openProfessionalByID:(NSString*)profid{
    
    if (IS_IPAD) {
        ProfPageViewController* profPageViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
        
        [profPageViewController setProfId:profid];
        [[[UIManager sharedInstance]pushDelegate].navigationController pushViewController:profPageViewController animated:YES];
        
    }else{
        
        ProfessionalPageViewController_iPhone * ipv= [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
        ProfessionalDO * prof = [[ProfessionalDO alloc] init];
        prof._id = profid;
        ipv.professional = prof;
        
        [[[UIManager sharedInstance]pushDelegate].navigationController pushViewController:ipv animated:YES];
    }
}

-(void)resetPasswordPressed:(UIViewController*)senderView{
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [self showAlert];
        return;
    }
    
    if(_resetPasswordController == nil)
    {
        _resetPasswordController= [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileResetPassword" inStoryboard:kNewProfileStoryboard];
        
        [senderView addChildViewController:_resetPasswordController];
        [senderView.view addSubview:_resetPasswordController.view];
        
    } else {
        
        if ([_resetPasswordController parentViewController]==senderView) {
            [_resetPasswordController.view removeFromSuperview];
            [_resetPasswordController removeFromParentViewController];
        }else{
            
            if([[_resetPasswordController view] superview]!=nil)
            {
                [_resetPasswordController.view removeFromSuperview];
                [_resetPasswordController removeFromParentViewController];
            }
            [senderView addChildViewController:_resetPasswordController];
            [senderView.view addSubview:_resetPasswordController.view];
        }
    }
}

-(void)openSettingsPressed:(UIViewController*)senderView{
    if(_settingsViewController == nil)
    {
        _settingsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"settingsViewController" inStoryboard:kMainStoryBoard];
    }else{
        
        if ([_settingsViewController parentViewController] == senderView) {
            [_settingsViewController.view removeFromSuperview];
            [_settingsViewController removeFromParentViewController];
        }else{
            if([[_settingsViewController view] superview]!=nil)
            {
                [_settingsViewController.view removeFromSuperview];
            }
        }
    }
    
    [senderView addChildViewController:_settingsViewController];
    //_settingsViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [senderView.view addSubview:_settingsViewController.view];
    
//    [UIView animateWithDuration:0.5
//                          delay:0.0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:0.3
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         _settingsViewController.view.transform = CGAffineTransformIdentity;
//                     } completion:^(BOOL finished) {
//                         [_settingsViewController startBgAnimation];
//                     }];
    [_settingsViewController startBgAnimation];
}

-(void)openAboutPagePressed:(UIViewController*)senderView{
    
    if(_aboutViewController == nil)
    {
        _aboutViewController= [ControllersFactory instantiateViewControllerWithIdentifier:@"aboutViewController" inStoryboard:kMainStoryBoard];
        
        [senderView addChildViewController:_aboutViewController];
        [senderView.view addSubview:_aboutViewController.view];
        
    } else {
        
        if ([_aboutViewController parentViewController]==senderView) {
            [_aboutViewController.view removeFromSuperview];
            [_aboutViewController removeFromParentViewController];
        }else{
            
            if([[_aboutViewController view] superview]!=nil)
            {
                [_aboutViewController.view removeFromSuperview];
                [_aboutViewController removeFromParentViewController];
            }
            [senderView addChildViewController:_aboutViewController];
            [senderView.view addSubview:_aboutViewController.view];
        }
    }
}

-(void)openTermsPagePressed:(UIViewController*)senderView{
    
    if(_termsViewController == nil){
        _termsViewController= [ControllersFactory instantiateViewControllerWithIdentifier:@"aboutViewController" inStoryboard:kMainStoryBoard];
        
        _termsViewController.isTermsScreen=true;
        
        [senderView addChildViewController:_termsViewController];
        [senderView.view addSubview:_termsViewController.view];
    }else {
        if ([_termsViewController parentViewController]==senderView) {
            [_termsViewController.view removeFromSuperview];
            [_termsViewController removeFromParentViewController];
        }else{
            if([[_termsViewController view] superview]!=nil)
            {
                [_termsViewController.view removeFromSuperview];
                [_termsViewController removeFromParentViewController];
            }
            [senderView addChildViewController:_termsViewController];
            [senderView.view addSubview:_termsViewController.view];
        }
    }
}

#pragma mark - iPhone related menus
- (void) professionalsIphonePressed:(id)sender{
    if (![ConfigManager isAnyNetworkAvailable]) {
        [self showAlert];
        return;
    }
    
    ProfIndexViewController_iPhone * profIndexViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfIndexViewController" inStoryboard:kProfessionalsStoryboard];

    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profIndexViewController animated:YES];

    BOOL isPresentedView = [[UIManager sharedInstance] pushDelegate].navigationController.topViewController != sender;

    if (isPresentedView) {
        [sender dismissViewControllerAnimated:YES completion:^{}];
    }
}

-(void)openSettingsIphone{
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]) {
        [self showAlert];
        return;
    }
    
    SettingsViewController_iPhone* settingsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"SettingsViewController_iPhone" inStoryboard:kMainStoryBoard];

    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:settingsViewController animated:YES];
}

- (void)newDesignPressedIphone
{
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]) {
        [self showAlert];
        return;
    }
    
    if (_newDesignViewControllerIphone == nil){
        _newDesignViewControllerIphone = [ControllersFactory instantiateViewControllerWithIdentifier:@"NewDesignViewID" inStoryboard:kMainStoryBoard];
    }
    
    if ([[[[UIManager sharedInstance] pushDelegate].navigationController viewControllers] count] > 1) {
        [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    }
    
//    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:nd animated:YES];
    
    [UIView transitionWithView:[[UIManager sharedInstance] pushDelegate].navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve 
                    animations:^ { [[[UIManager sharedInstance] pushDelegate].navigationController.view addSubview:_newDesignViewControllerIphone.view]; }
                    completion:nil];
    
    [[[UIManager sharedInstance] pushDelegate].navigationController addChildViewController:_newDesignViewControllerIphone];
}

-(void)openAboutPageIphonePressed:(UIViewController*)senderView{
    
    AboutViewController * _aboutIphoneViewController= [ControllersFactory instantiateViewControllerWithIdentifier:@"aboutViewController" inStoryboard:kMainStoryBoard];
    
    [senderView.navigationController pushViewController:_aboutIphoneViewController animated:YES];
}

-(void)showAlert{
    [ConfigManager showMessageIfDisconnected];
}

-(void)backPressed:(UIViewController*)senderView
{
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
}

-(void)returnToInitialPage{
    [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    [self.menuViewController setMenuButtonSelection:kMenuOptionTypeNone];
}

-(void)refreshMenu
{
    if(_menuViewController)
    {
        [_menuViewController refreshPanelButtonsState];
    }
}

#pragma mark - New Like Implementation
- (void)loginRequestedIphone:(UIViewController *)senderView withCompletionBlock:(void (^)(BOOL success))block loadOrigin:(NSString *)loadOriginEvent {
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        
        block(NO);
        return;
    }
    
    if (IS_IPAD)
    {
        [self showLoginViewController:loadOriginEvent viewController:senderView];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if ([ConfigManager isSignInSSOActive]) {

                [MGJRouter openURL:@"/UserCenter/LogIn"];
            }else if ([ConfigManager isSignInWebViewActive]) {
                GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
                [senderView presentViewController:web animated:YES completion:nil];
            }else{
                UINavigationController * navbar = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
                
                UserLoginViewController_iPhone * viewop = [[navbar viewControllers] objectAtIndex:0];
                viewop.eventLoadOrigin = loadOriginEvent;
                viewop.openingType = eModal;
                
                [senderView presentViewController:navbar animated:YES completion:nil];
            }
        });
    }
}

-(void)showLoginViewController:(NSString *)loadOriginEvent viewController:(UIViewController *)senderView{

    UserLoginViewController * userLoginViewController = userLoginViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
    userLoginViewController.eventLoadOrigin = loadOriginEvent;
    
    if (IS_IPAD) {
        if ([ConfigManager isSignInSSOActive]) {
            SHRNViewController *ulController = [[SHRNViewController alloc] init];
            [senderView.navigationController pushViewController:ulController animated:NO];
        }else if ([ConfigManager isSignInWebViewActive]) {
            [ExternalLoginViewController showExternalLogin:senderView];
        }else{
            userLoginViewController.openingType = ePush;
            [senderView.navigationController pushViewController:userLoginViewController animated:YES];
        }
    }else{
        
        if ([ConfigManager isSignInSSOActive]) {

            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }else if ([ConfigManager isSignInWebViewActive]) {
             GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
             [senderView.navigationController pushViewController:web animated:YES];
         }else{
             userLoginViewController.openingType = ePush;
             [senderView.navigationController pushViewController:userLoginViewController animated:YES];
         }
    }
}

- (void)loginRequestedIphone:(UIViewController *)senderView loadOrigin:(NSString *)loadOriginEvent {
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        return;
    }
    
    if ([ConfigManager isSignInSSOActive]) {

        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }else if ([ConfigManager isSignInWebViewActive]) {
        if (IS_IPAD) {
            [ExternalLoginViewController showExternalLogin:senderView];
        }else{
            GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
            [senderView presentViewController:web animated:YES completion:nil];
        }
    }else{
        UINavigationController * navbar = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
        UserLoginViewController_iPhone * viewop=[[navbar viewControllers] objectAtIndex:0];
        viewop.openingType = eModal;
        viewop.eventLoadOrigin = loadOriginEvent;
    
        [senderView presentViewController:navbar animated:YES completion:Nil];
    }
}

- (void)loginRequestedIpad:(UIViewController *)senderView
                loadOrigin:(NSString *)loadOriginEvent {

    [self showLoginViewController:loadOriginEvent viewController:senderView];
}

#pragma mark - UserLogInDelegate Protocol

- (void)loginSucceeded
{
}

- (void)loginFailed
{
}


#pragma mark - Design Stream Sort Filter

- (NSString *)getSortTypeForDesignStreamType:(NSString *)type
{
    if ((_isUserChangedFilter) && (_currentSortTypeFilter != nil))
    {
        return _currentSortTypeFilter;
    }
    else
    {
        if ([type rangeOfString:DesignStreamType3D].location != NSNotFound)
        {
            return DesignSortTypeFor3D;
        }
        else if ([type rangeOfString:DesignStreamType2D].location != NSNotFound)
        {
            return DesignSortTypeFor2D;
        }
        else if ([type rangeOfString:DesignStreamTypeArticles].location != NSNotFound)
        {
            return DesignSortTypeForArticles;
        }
    }
    
    return @"1";
}

- (NSString *)getLocalizedStringForSortType:(NSString *)type
{
    if ([type rangeOfString:@"1"].location != NSNotFound)
    {
        return NSLocalizedString(@"editor_choice_sort", @"Editor's Choice");
    }
    else if ([type rangeOfString:@"2"].location != NSNotFound)
    {
        return NSLocalizedString(@"new_sort", @"New");
    }
    else if ([type rangeOfString:@"3"].location != NSNotFound)
    {
        return NSLocalizedString(@"popularity_sort", @"Popularity");
    }
    
    return  NSLocalizedString(@"editor_choice_sort", @"Editor's Choice");
}

- (void)setCurrentSortTypeFilter:(NSString *)filter
{
    _currentSortTypeFilter = filter;
}

#pragma mark - Mail Generation

- (void)createEmailWithTitle:(NSString *)title andBody:(NSString *)body forPresentingTarget:(UIViewController <MFMailComposeViewControllerDelegate> *)target withRecipients:(NSArray *)toAddresses {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = target;
        
        
        
        // Attach an image to the email.
        
        NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
        if(dict!=NULL){
            
            [mailViewController setSubject: NSLocalizedString(@"feedback_email_subject",@"Share with Homestyler Team")];
            NSString * body=@"";
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            struct utsname systemInfo;
            uname(&systemInfo);
            
            NSString * dd = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            NSString *osversion=[UIDevice currentDevice].systemVersion;
            body=[NSString stringWithFormat:@"\n\n\n----------------------------------------\n%@ version: %@-%@\n Device: %@\nVersion: %@",[ConfigManager getAppName], version,build,dd,osversion];
            [mailViewController setMessageBody:body isHTML:NO];
            
            if(toAddresses)
                [mailViewController setToRecipients:toAddresses];
            
        }
        // Present the view controller
        
        [target presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        HSMDebugLog(@"Device is unable to send email in its current state.");
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
    }
}

- (BOOL)isOptionActive:(NSString*)option{
    if (!option || [option isEqualToString:@""]) {
        return NO;
    }
    
    // Path to the plist (in the application bundle)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Bootstrap" ofType:@"plist"];
    
    // Build the array from the plist
    NSDictionary * bootstrapDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSDictionary * featuresDict = [bootstrapDict objectForKey:@"Features"];
    //order in the array is important!!!
    return [[featuresDict objectForKey:option] boolValue];
}

- (void)refreshPanelButtonsState {
    
    if (self.menuViewController) {
        [self.menuViewController refreshPanelButtonsState];
    }
}

@end
