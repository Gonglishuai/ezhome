
//
//  NewBaseProfileViewController.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "NewBaseProfileViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AppCore.h"
#import "UserRO.h"
#import "OtherUserRO.h"
#import "ControllersFactory.h"
#import "UserLikesDO.h"
#import "UserProfileBaseTableViewController.h"
#import "MyDesignEditBaseViewController.h"
#import "ArticleItemCollectionView.h"
#import "FollowUserItemCollectionView.h"
#import "ProfileInstanceBaseViewController.h"
#import "ProfileFollowingsViewController.h"
#import "ProfileDesignsViewController.h"
#import "ProfileFollowersViewController.h"
#import "ProfileArticlesViewController.h"
#import "ProfileProfessionalsViewController.h"
#import "ProfileActivitiesViewController.h"
#import "ProfPageViewController.h"
#import "ProfileCountsDO.h"
#import "UserExtendedDetails.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "NSString+Contains.h"
#import "NotificationNames.h"
#import "ProgressPopupViewController.h"
#import "UserLoginViewController_iPhone.h"
#import "DesignsManager.h"
#import "ServerUtils.h"
#import "SHRNViewController.h"

#define MAX_LENGTH_NAME         100
#define MAX_LENGTH_DESCRIPTION  1000

static BOOL bNeedToRefreshProfile = NO;

@interface NewBaseProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIPopoverController* imageGalleryPopover;
@property (nonatomic) BOOL shouldAlertCloseScreen;
@property (nonatomic) BOOL didTrySilentLogin;
@property (nonatomic, strong) ProfileCountsDO *profileCounts;
@property (nonatomic) ProfileTabs pendingProfileTabSelection;
@end

@implementation NewBaseProfileViewController
{
    BOOL oneSelectionAtATime;
}

#pragma mark - Overrides
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    oneSelectionAtATime = YES;
    self.profileCounts = [ProfileCountsDO  new];
    self.pendingProfileTabSelection = ProfileTabUnknown;
    
    self.shouldAlertCloseScreen = NO;
    
    // Load the info if needed
    if (self.userId)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginDone:) name:@"SinginFacebookCompleteNotification" object:nil];
    }
    
    if (self.isLoggedInUserProfile) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDisplay) name:FFFollowStatusChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signoutCalled) name:kNotificationUserDidLogout object:nil];
    }
    
    //refresh content after sync
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserProfileAccordingToUserID) name:@"DesignManagerSyncCycleComplete" object:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc {
    NSLog(@"dealloc - NewBaseProfileViewController");
}

- (IBAction)backPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SinginFacebookCompleteNotification"  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FFFollowStatusChangedNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationUserDidLogout  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DesignManagerSyncCycleComplete"  object:nil];

    self.profileCounts = nil;
    self.tempDesignPressed = nil;
    self.delegate = nil;
    self.editDesignViewController = nil;
    self.profileMenuController = nil;
    self.currentPresentingPage = nil;
    self.profileFollowingsVC = nil;
    self.profileDesignsVC = nil;
    self.profileFollersVC = nil;
    self.profileArticlesVC = nil;
    self.profileProfessionalsVC = nil;
    self.profileActivitiesVC = nil;
    self.profileUserDetailsVC = nil;
    self.profileEditUserDetailsVC = nil;
    
    [self.loadingStatus removeAllObjects];
    self.loadingStatus = nil;
    
    [self closeScreen];
}

- (void)signoutCalled
{
    if (self.isLoggedInUserProfile) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[[UIManager sharedInstance] pushDelegate].navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)facebookLoginDone:(NSNotification*)notification{
    [self loadUserProfileAccordingToUserID];
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    
    self.isLoggedInUserProfile = [userId isEqual:[[[UserManager sharedInstance] currentUser] userID]];
    
    if (self.isLoggedInUserProfile){
//        [HSFlurry logAnalyticEvent:EVENT_NAME_MY_PROFILE_VISITED];
    }else{
        NSString * visitorId=@"";
        if ([[UserManager sharedInstance] isLoggedIn] && [[UserManager sharedInstance] currentUser]!=nil) {
            visitorId=([[[UserManager sharedInstance] currentUser] userID])?[[[UserManager sharedInstance] currentUser] userID]:@"";
        }
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_PROFILE_VISITED
//                    withParameters:@{EVENT_PARAM_PROFILE_VISIT_ID:(userId)?userId:@"",
//                                     EVENT_PARAM_PROFILE_VISITOR_ID:visitorId}];
    }
}

- (void)setUserProfile:(UserProfile *)currUserProfile
{
    _userProfile = currUserProfile;
    
    [self initProfileCounters];
    
    BOOL readOnlyProfile = !self.isLoggedInUserProfile;
    
    [self.profileMenuController setUserProfile:currUserProfile isReadOnlyProfile:readOnlyProfile];
    
    // Other user profile / current user is facebook user
    self.ProfileMenuContainerView.hidden = NO;
        
    [self updateDisplay];
    
    if(self.profileEditRequestedAfterProfileLoad){
        self.profileEditRequestedAfterProfileLoad=NO;
        [self.profileMenuController editProfileAction:nil];
    }
}

- (void)initProfileCounters {
    
    self.profileCounts.followers=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.followers];
    self.profileCounts.following=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.following];
    self.profileCounts.designs=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.publishedAssets];
    self.profileCounts.professionals=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.followedProfessionals];
    self.profileCounts.articles=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.favoriteArticles];
    self.profileCounts.profileViews=[[NSMutableString alloc] initWithFormat:@"%ld",(long)self.userProfile.extendedDetails.viewCount];
}

#pragma mark- ProfileCountersDelegate

-(void)updateProfileCounterString:(NSString *)value ForTab:(ProfileTabs)tab{
    switch (tab){
        case ProfileTabUnknown:
            
            break;
        case ProfileTabActivities:
            if (self.isLoggedInUserProfile && [value intValue]>0) {
                [self.profileCounts.activities setString:value];
            }else
            {
                [self.profileCounts.activities setString:[NSString stringWithFormat:@""]];
            }
            break;
        case ProfileTabDesign:
            [self.profileCounts.designs setString:value];
            break;
        case ProfileTabFollowers:
            [self.profileCounts.followers setString:value];
            break;
        case ProfileTabFollowing:
            [self.profileCounts.following setString:value];
            break;
        case ProfileTabArticles:
            [self.profileCounts.articles setString:value];
            break;
        case ProfileTabProfessionals:
            [self.profileCounts.professionals setString:value];
            break;
            
        default:
            break;
    }
}

-(void)updateProfileCounter:(int)value ForTab:(ProfileTabs)tab{
    [self updateProfileCounterString:[NSString stringWithFormat:@"%d",value] ForTab:tab];
}

-(NSString*)getProfileCounterValueFor:(ProfileTabs) tab{
    switch (tab){
        case ProfileTabUnknown:
            
            break;
        case ProfileTabActivities:
            return self.profileCounts.activities ;
            
        case ProfileTabDesign:
            return self.profileCounts.designs;
            
        case ProfileTabFollowers:
            return self.profileCounts.followers;
            
        case ProfileTabFollowing:
            return self.profileCounts.following;
            
        case ProfileTabArticles:
            return self.profileCounts.articles;
            
        case ProfileTabProfessionals:
            return self.profileCounts.professionals;
        case ProfileTaUnvisibleProfileViewer:
            return self.profileCounts.profileViews;
        default:
            return @"";
    }
    
    return @"";
}

-(void)increaseProfileCounterForTab:(ProfileTabs)tab{
    
    NSString* currentCount=[self getProfileCounterValueFor:tab];
    [self updateProfileCounter: [currentCount intValue]+1 ForTab:tab];
}

-(void)decreaseProfileCounterForTab:(ProfileTabs)tab{
    NSString* currentCount=[self getProfileCounterValueFor:tab];
    
    int value=[currentCount intValue]-1;
    if(value<0)
    {
        value=0;
    }
    [self updateProfileCounter: value ForTab:tab];
}

- (void)updateDisplay
{
    //update design collection view
    [self.profileDesignsVC populateViewController:self.userProfile.assets isSignInUser:self.isLoggedInUserProfile];

    [self.profileMenuController updateMasterMenuDisplay];
    
    [[self.currentPresentingPage getContentVC] updateDisplay:self.isLoggedInUserProfile];
}

- (void)loadUserProfileAccordingToUserID
{
    if ([ConfigManager showMessageIfDisconnectedWithDelegate:self]) {
        self.shouldAlertCloseScreen = YES;
        return;
    }
    
    self.loadingStatus = [@[@(LoadingStatusLoading),
                            @(LoadingStatusDelayed),
                            @(LoadingStatusDelayed),
                            @(LoadingStatusDelayed),
                            @(LoadingStatusDelayed)] mutableCopy];
    
    // Blocks
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        UserProfile* profile = serverResponse;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];

            [self updateStatus:LoadingStatusSuccess forTab:ProfileTabDesign];
            
            // Profile loaded
            if (profile && profile.errorCode < 0)
            {
                [profile updateDesignUids:self.userId];
                
                if ( [profile.userPhoto rangeOfString:@"graph.facebook.com/"].location!=NSNotFound &&
                    [profile.userPhoto rangeOfString:@"?type=large"].location==NSNotFound) {
                    profile.userPhoto=[NSString stringWithFormat:@"%@?type=large",profile.userPhoto];
                }
                
                self.userProfile = profile;
            }
            else
            {
                // Profile wasn't loaded
                if (self.isLoggedInUserProfile && !self.didTrySilentLogin)
                {
                    self.didTrySilentLogin = YES;
                    [self silentLoginTry];
                }
                else
                {
                    [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading_other",@"An error occured while trying to load the profile")];
                    self.shouldAlertCloseScreen = YES;
                }
            }
        });
    };
    
    ROFailureBlock failureBlock = ^(NSError* error) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        [self updateStatus:LoadingStatusFailure forTab:ProfileTabDesign];
        if (self.isLoggedInUserProfile){
            [[AppCore sharedInstance] logoutUser];
        }
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading",@"An error occured while trying to load the profile")];
        self.shouldAlertCloseScreen = YES;
    };
    
    ROFailureBlock failureBlock2 = ^(NSError* error) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        [self updateStatus:LoadingStatusFailure forTab:ProfileTabDesign];
        if (self.isLoggedInUserProfile){
            [[AppCore sharedInstance] logoutUser];
        }
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading_other",@"An error occured while trying to load the profile")];
        self.shouldAlertCloseScreen = YES;
    };
    
    
    // Send my profile / public profile request
    if (self.isLoggedInUserProfile)
    {
        [[HomeManager sharedInstance] getMyProfile:completionBlock
                                      failureBlock:failureBlock];
    }
    else
    {
        [[OtherUserRO new] getUserProfileById:self.userId
                              completionBlock:completionBlock
                                 failureBlock:failureBlock2 queue:dispatch_get_main_queue()];
    }
}

- (void)silentLoginTry
{
    [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
        
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (error==nil && response!=nil && response.errorCode==-1) {
            [self loadUserProfileAccordingToUserID];
        }else
        {
            [self showErrorWithMessage:NSLocalizedString(@"err_msg_profile_loading",@"An error occured while trying to load the profile")];
            self.shouldAlertCloseScreen = YES;
        }
        
    } queue:dispatch_get_main_queue()];
}

- (void)updateStatus:(LoadingStatuses)status
              forTab:(ProfileTabs)tab
{
    self.loadingStatus[tab] = @(status);
}

#pragma mark - MyDesignEditDelegate
- (void)designUpdated:(DesignMetadata *)metadata {
    [self refreshView];
}

- (void)designDuplicated:(NSString *)designId {
    [self refreshView];
}

- (void)designDeleted:(NSString *)designId {
    [self refreshView];
}

- (void)refreshView
{
    [self updateDisplay];
}

- (void)initDisplay{
    //inplement in son's
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = textField.text.length + string.length - range.length;
    return (newLength > MAX_LENGTH_NAME) ? NO : YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = textView.text.length + text.length - range.length;
    return (newLength > MAX_LENGTH_DESCRIPTION) ? NO : YES;
}

#pragma mark - Change image

- (BOOL)startMediaBrowse:(CGRect)rect
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.allowsEditing = NO;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.delegate = self;
    // Check which device
    if (IS_IPAD) {
        self.imageGalleryPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [self.imageGalleryPopover setDelegate:self];
        [self.imageGalleryPopover presentPopoverFromRect:rect
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionUp
                                                animated:YES];
    } else {
        [self presentViewController:picker animated:YES completion:nil];
    }
    return YES;
}

- (void) imagePickerController:(UIImagePickerController *)picker
 didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    // Check media type
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        // Clear the image
        self.userProfile.userPhoto = nil;
        
        [self.profileEditUserDetailsVC updateProfileImage:(UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage]];
    }
    
    // Close the popover / modal VC
    if (IS_IPAD) {
        [self.imageGalleryPopover dismissPopoverAnimated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^ {
            [picker dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	self.imageGalleryPopover = nil;
}

- (void)uploadImage:(UIImage*)image withCompletionBlock:(HSCompletionBlock)completion
{
    //imgmaayan
    [self logFlurryEvent:FLURRY_CHANGE_PROFILE_IMAGE];
    
    NSString * profileImage= [[[UserManager sharedInstance] currentUser] userProfileImage];
    
    // Clear local file before update
    if (profileImage) {
        NSString * filename=[profileImage lastPathComponent];
        NSString* imagePath =[NSString stringWithFormat:@"%@/profileView%@",[[ConfigManager sharedInstance] getStreamsPath]
                              ,filename];
        
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        imagePath =[NSString stringWithFormat:@"%@/menuView%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];
        
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        imagePath =[NSString stringWithFormat:@"%@/comment_%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        
        imagePath =[NSString stringWithFormat:@"%@/commentrep_%@",[[ConfigManager sharedInstance] getStreamsPath]
                    ,filename];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
    
    [[ServerUtils sharedInstance] uploadNewPhoto:image completion:completion];
}

#pragma mark- ProfileMasterDelegate
-(void)profileTabSelectionChange:(ProfileTabs)newTab{
    
    if (self.currentProfileTab==newTab) {
        return;
    }
    
    //1. remove current view
    if(![self canLeaveCurrentScreen]){
        self.pendingProfileTabSelection =newTab;
        return;
    }
    
    self.currentProfileTab = newTab;
    [self.currentPresentingPage.view removeFromSuperview];
    [self.currentPresentingPage removeFromParentViewController];
    
    //2. choose new vc
    switch (newTab)
    {
        case ProfileTaUnvisibleProfileViewer:
        {
            self.profileUserDetailsVC = [[ProfileUserDetailsViewController_iPad alloc] initWithRect:self.detailsViewContainer.bounds];
            self.profileUserDetailsVC.isLoggedInUserProfile = self.isLoggedInUserProfile;
            self.profileUserDetailsVC.rootUserDelegate = self;
            [self.profileUserDetailsVC initContent];

            self.currentPresentingPage = self.profileUserDetailsVC ;
        }
            break;
        case ProfileEditProfileViewer:
        {
            self.profileEditUserDetailsVC = [[ProfileUserDetailsViewController_iPad alloc] initWithRect:self.detailsViewContainer.bounds];
            self.profileEditUserDetailsVC.isLoggedInUserProfile = self.isLoggedInUserProfile;
            self.profileEditUserDetailsVC.rootUserDelegate = self;
            self.profileEditUserDetailsVC.isEditingPresentation = YES;
            [self.profileEditUserDetailsVC initContent];
            
            self.currentPresentingPage = self.profileEditUserDetailsVC ;
        }
            break;
        case ProfileTabDesign:
        {
            self.currentPresentingPage = self.profileDesignsVC ;
        }
            break;
        case ProfileTabFollowers:
        {
            self.currentPresentingPage = self.profileFollersVC ;
        }
            break;
        case ProfileTabFollowing:
        {
            self.currentPresentingPage = self.profileFollowingsVC ;
        }
            break;
        
        case ProfileTabUnknown:
        {
            self.currentPresentingPage = self.profileProfessionalsVC;
        }
            break;
        case ProfileTabArticles:
        {
            self.currentPresentingPage = self.profileArticlesVC;
        }
            break;
        case ProfileTabProfessionals:
        {
            self.currentPresentingPage = self.profileProfessionalsVC;
            
        }
            break;
        case ProfileTabActivities:
        {
            self.currentPresentingPage = self.profileActivitiesVC;
        }
            break;
            
        default:
        {
            self.currentPresentingPage = self.profileDesignsVC ;
        }
            break;
    }
}

-(UserProfile*)getUserProfileObject{
    return self.userProfile;
}

- (BOOL)canLeaveCurrentScreen {
    if([self.currentPresentingPage isEqual:self.profileEditUserDetailsVC]){
        
        if([self.profileEditUserDetailsVC changeExists])
        {
            [self.profileEditUserDetailsVC askToLeaveWithoutSave];
            return NO;
        }
    }
    
    return YES;
}

-(void)openSignInDialog
{    
    if (IS_IPAD){
        
        if ([ConfigManager isSignInSSOActive]) {
            SHRNViewController *ulController = [[SHRNViewController alloc] init];
            [self.view addSubview: ulController.view];
            [self addChildViewController:ulController];
        }else if ([ConfigManager isSignInWebViewActive]) {
            [ExternalLoginViewController showExternalLogin:self];
        }else{
            UserLoginViewController* ulogin = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
            ulogin.openingType = eView;
            ulogin.view.frame = self.view.frame;
            [self.view addSubview: ulogin.view];
            [self addChildViewController:ulogin];
        }
    }
    else
    {
        //If we are in the process of silent login, do nothing and wait for the process to end
        if ([[UserManager sharedInstance] isSilenceLoggInProcess]) {
            return;
        }
        
        //Send infromation from wher log in poped up
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:EVENT_PARAM_VAL_SIGNIN_MENU_BUTTON, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
        
        
        if ([ConfigManager isSignInSSOActive]) {

            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }else if ([ConfigManager isSignInWebViewActive]) {
            GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
            [self presentViewController:web animated:YES completion:nil];
        }else{
            UINavigationController * navbar = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
            
            UserLoginViewController_iPhone * viewop = [[navbar viewControllers] objectAtIndex:0];
            
            viewop.openingType=eModal;
            viewop.eventLoadOrigin=EVENT_PARAM_LOAD_ORIGIN_MENU;
            [self presentViewController:navbar animated:YES completion:nil];
        }
    }
}

#pragma mark -ProfileInstanceDelegate

-(NSString*)getUserIDForCurrentProfile{
    
    if (self.userProfile)
    {
        return self.userProfile.userId;
    }
    
    if (_userId)
    {
        return _userId;
    }
    
    return nil;
}

- (void)followPressed:(FollowUserInfo *)info didFollow:(BOOL)follow
{
    //This method used for following any user from followers/following list for my profile or
    //any other profile. Also its activated from Follow button of viewed profile.
    
    if ([[UserManager sharedInstance]isLoggedIn] == NO) {
        //No user is logged in
        [self openSignInDialog];
        return;
    }
    
    // Update the client
    info.isFollowed = follow;
    
    // Update the server
    if (info.type == FollowUserTypProfessional)
    {
        [[[AppCore sharedInstance] getProfsManager]followProfessional:info.userId followStatus:follow completionBlock:^(id serverResponse, id error) {
        } queue:dispatch_get_main_queue()];
    }
    else
    {
        [[HomeManager sharedInstance] followUser:info.userId follow:follow withCompletion:nil failureBlock:nil queue:dispatch_get_main_queue()];
    }
    
    //if logged in user started following/unfollowing his followers/following
    if (self.isLoggedInUserProfile)
    {
        //update current user pr
        [self.profileFollowingsVC addOrRemoveFollowUser:info andFollowStatus:follow];
    }else{
        
        //in anyway when logged in user is un/following some update his homemanager list
        if (follow) {
            [[HomeManager sharedInstance] addFollowingUser:info];
        }else{
            [[HomeManager sharedInstance]removeFollowingUser:info];
        }
        
        
        // If the logged in user started following other profile user
        //then create current user as follower of current profile
        if ([info.userId isEqualToString:self.userId])
        {
            // Create logged in user
            FollowUserInfo* currUser = [FollowUserInfo new];
            currUser.userId = [[[UserManager sharedInstance] currentUser]userID];
            currUser.firstName = [[[UserManager sharedInstance] currentUser]firstName];
            currUser.lastName = [[[UserManager sharedInstance] currentUser]lastName];
            currUser.photoUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
            currUser.type = FollowUserTypeNormal;
            currUser.isFollowed = follow;
            
            [self.profileFollersVC addOrRemoveFollowUser:currUser andFollowStatus:follow];
            
            //also add this followed user into logged in user's following list
        }
    }
    
    [self updateDisplay];
}

#pragma mark - FollowUserItemDelegate
- (void)userPressed:(FollowUserInfo *)info
{
    if (![info.userId isEqual:self.userId])
    {
        if (info.type != FollowUserTypProfessional)
        {
            [self openUserProfilePageController:info.userId];
        }
        else
        {
            [self professionalPressed:info.userId];
        }
    }
}

- (void)openUserProfilePageController:(NSString *)infoUserID {
    NewBaseProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    [profileViewController setUserId:infoUserID];
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - ProfessionalCellDelegate
- (void)professionalPressed:(NSString *)professionalId
{
    ProfPageViewController* profPageViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
    [profPageViewController setProfId:professionalId];
    [self.navigationController pushViewController:profPageViewController animated:YES];
}

#pragma mark - DesignItemDelegate
- (void)designEditPressed:(MyDesignDO *)design {
    if (oneSelectionAtATime == NO)
        return;

    oneSelectionAtATime = NO;

    self.editDesignViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"MyDesignsEditViewController" inStoryboard:kNewProfileStoryboard];

    self.editDesignViewController.design = design;
    self.editDesignViewController.delegate = self;

    [self.editDesignViewController presentByParentViewController:self animated:YES completion:^{
        oneSelectionAtATime = YES;
    }];
}

- (void)startRedesignTool
{
    SavedDesign * saveDesign = [[DesignsManager sharedInstance] workingDesign];
    
    GalleryItemDO * gido = (GalleryItemDO*)self.tempDesignPressed;
    [[UIManager sharedInstance] galleryDesignSelected:saveDesign withOriginalDesign:gido  withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];
    [[UIManager sharedInstance] galleryDesignBGImageRecieved:saveDesign.image andOrigImage:saveDesign.originalImage andMaskImage:saveDesign.maskImage];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView message]isEqualToString:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"")]) {
        switch ( buttonIndex) {
            case 0:
                [self startRedesignTool];
                break;
            case 1:
                //do nothing
            default:
                break;
        }
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"signout_confirm_alert", @"")]) {
        
        switch (buttonIndex) {
            case 0:
            {
//                [HSFlurry logAnalyticEvent:EVENT_NAME_SIGN_OUT];
                [[AppCore sharedInstance] logoutUser];
                
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                [self.delegate profileSignOutPressed];
            }
                break;
            case 1:
                
                break;
            default:
                break;
        }
    }
}

- (void)designPressed:(MyDesignDO *)asset {
    [self redesign:asset];
}

- (void)redesign:(MyDesignDO *)asset
{
    self.tempDesignPressed = asset;
    NSMutableArray * designs = [self.userProfile.assets mutableCopy];
    
    if (asset.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"Please Redesign and Save this design in order to make any changes")
                                   delegate:self cancelButtonTitle:NSLocalizedString(@"resume_alert_button", @"")
                          otherButtonTitles:NSLocalizedString(@"alert_msg_button_cancel", @""), nil] show];
        return;
    }
    
    for (int i = 0; i< designs.count; i++) {
        MyDesignDO * md = [designs objectAtIndex:i];
        if (md.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
            [designs removeObject:md];
            i--;
        }
    }
    
    NSInteger selectedDesignIdx = [designs indexOfObject:asset];
    //Fix getmyProfile twice bug
    [self openGalleryFullScreen:designs selectedDesignIdx:selectedDesignIdx];
}

- (void)openGalleryFullScreen:(NSArray *)designs selectedDesignIdx:(NSInteger)selectedDesignIdx{
    [NewBaseProfileViewController needToRefreshProfile :YES];
    
    FullScreenBaseViewController* fsbVc = [[UIManager sharedInstance] createFullScreenGallery:designs
                                                                            withSelectedIndex:(int)selectedDesignIdx
                                                                                  eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE ];
    fsbVc.sourceViewController = self;
    fsbVc.dataSourceType = eFScreenUserDesigns;
    [self.navigationController pushViewController:fsbVc animated:YES];
}

#pragma mark - ArticleItemDelegate
- (void)articlePressed:(GalleryItemDO*)article fromArticles:(NSArray*)allArticles{
    [self openGalleryFullScreen:allArticles selectedDesignIdx:[allArticles indexOfObject:article]];
}

#pragma mark - ActivityTableCellDelegate

- (void)openHelpEmailPage{
    
}

- (void)openUserProfilePage:(NSString *)profileId{
    [self openUserProfilePageController:profileId];
}

- (void)openFullScreen:(NSString *)designId withType:(ItemType)type{
    switch (type) {
        case e3DItem:
            [self openDesignFullScreen:designId];
            break;
        case e2DItem:
            [self openPhotoFullScreen:designId];
            break;
        case eArticle:
            [self openArticleFullScreen:designId];
            break;
        default:
            break;
    }
}

- (void)openPhotoFullScreen:(NSString *)designId
{
    [[UIManager sharedInstance] openGalleryFullScreenFromDesignID:NO designid:designId withType: e2DItem eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE];
}

- (void)openDesignFullScreen:(NSString *)designId
{
    [[UIManager sharedInstance] openGalleryFullScreenFromDesignID:NO designid:designId withType: e3DItem  eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE];
}

- (void)openArticleFullScreen:(NSString *)articleId
{
    [[UIManager sharedInstance] openGalleryFullScreenFromDesignID:NO designid:articleId withType: eArticle eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE];
}

- (BOOL)isCurrentCellOfLoggedInUser
{
    return self.isLoggedInUserProfile;
}

//
// Following a user using an FollowUserInfo
//
- (void)followUser:(FollowUserInfo *)followUser
{
    [self followPressed:followUser didFollow:YES];
}

//
// Unfollowing a user using an id string
// See remarks above in "followUser:followUserId"
//
- (void)unfollowUser:(NSString *)followUserId
{
    FollowUserInfo *userInfo = [FollowUserInfo new];
    userInfo.userId = followUserId;
    userInfo.type = FollowUserTypeNormal;
    [self followPressed:userInfo didFollow:NO];
}

- (void)openCommentScreenForDesign:(NSString *)designId withType:(ItemType)type
{
    if (IS_IPAD) {
        
        NSMutableArray * designs = [self.userProfile.assets mutableCopy];
        NSInteger idx = NSNotFound;
        
        for (int i = 0; i < [designs count]; i++) {
            MyDesignDO * md = [designs objectAtIndex:i];
            if ([md._id isEqualToString:designId]) {
                idx = i;
                break;
            }
        }
        
        if (idx != NSNotFound) {
            FullScreenBaseViewController* fsbVc = [[UIManager sharedInstance] createFullScreenGallery:designs
                                                                                    withSelectedIndex:idx
                                                                                          eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE ];
            fsbVc.sourceViewController = self;
            fsbVc.dataSourceType = eFScreenUserDesigns;
            fsbVc.openCommentsLayer = YES;
            [self.navigationController pushViewController:fsbVc animated:YES];
        }
    }else{
        [[UIManager sharedInstance] openGalleryFullScreenFromDesignID:YES designid:designId withType:type  eventOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_USER_PROFILE];
    }
}

//returns a view controller to peresent login view etc on it, in case of need.
- (UIViewController *)delegateViewController
{
    return self;
}

- (void)changePasswordRequested {
    
    [self changePasswordPressed];
}

-(void)signoutRequested{
    [self signOutPressed];
}

- (void)askToLeaveWithoutSave {
    
    if( self.pendingProfileTabSelection!=ProfileTabUnknown){
        [self profileTabSelectionChange:self.pendingProfileTabSelection];
        self.pendingProfileTabSelection=ProfileTabUnknown;
    }else{
        //or exit from profile page if pending profile tab is unknown
        [self closeScreen];
    }
}

- (void)askToLeaveWithSaveAction {
    [self.profileEditUserDetailsVC leaveProfileEditingWithSaveChanges:nil];
}

-(void)leaveProfileEditingWithoutChanges{
    
//    if (self.isLoggedInUserProfile) {
//        [self.profileMenuController openActivityTab];
//    }else{
        [self.profileMenuController openDesignsTab];
//    }
}

-(void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser{
    //TODO: make save request , including image update
    
    if ([NSString isNullOrEmpty:deltaUser.firstName] || [NSString isNullOrEmpty:deltaUser.lastName])
    {
        [self showErrorWithMessage:NSLocalizedString(@"err_msg_enter_new_full_name",@"Please enter you first/last name")];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        return ;
    }
    
    HSCompletionBlock updateBlock=^(id serverResponse, id error) {
        
        //will update image url for the profile
        if(serverResponse && [serverResponse isKindOfClass:[NSString class]]){
            
            deltaUser.userProfileImage=serverResponse;
        }
        //TODO: Sergei- Decide where to navigate after Edit Mode
        if( self.pendingProfileTabSelection==ProfileTabUnknown){
            self.pendingProfileTabSelection = ProfileTabDesign;
        }
        
        [[UserManager sharedInstance] updateUserInfoWithDO:deltaUser completionBlock:^(id serverResponse, id error) {
            if (error) {
                [self showErrorWithMessage:NSLocalizedString(@"err_msg_update_user_info",@"Failed to update user info")];
            }else{
                BaseResponse * response=(BaseResponse*)serverResponse;
                
                if (response.errorCode==-1) {
                    
                    //update was successful,
                    
                    //update profile data
                    [self.userProfile updateUserProfileAccoringToUpdatedUser:deltaUser];
                    // refresh Master Menu content.
                    [self.profileMenuController updateMasterMenuDisplay];
                    
                    //refresh
                    if( self.pendingProfileTabSelection!=ProfileTabUnknown){
                        [self.profileEditUserDetailsVC disregardChangesOnProfileObject];
                    }
                }else{
                    [self showErrorWithMessage:NSLocalizedString(@"err_msg_update_user_info",@"Failed to update user info")];
                    [self.profileEditUserDetailsVC disregardChangesOnProfileObject];
                }
            }
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            
        } queue:dispatch_get_main_queue()];
    };
    
    //if photo changed upload it
    if (deltaUser.tempEditProfileImage) {
        [self uploadImage:deltaUser.tempEditProfileImage withCompletionBlock:updateBlock];
    }else{
        updateBlock(nil,nil);
    }
}

- (void)changeUserProfileImageRequestedForRect:(UIView*)mview {
    [self logFlurryEvent:FLURRY_PROFILE_EDIT_IMAGE_CLICK];
    CGRect rect=[self.view convertRect:mview.frame fromView:mview.superview];
    [self startMediaBrowse:rect];
}

-(UIView*)getParentView{
    
    return self.view;
}

-(void)startProfileEditingAfterRegistration{
    
    
    self.profileEditRequestedAfterProfileLoad=YES;
}

#pragma mark - Likes logic
- (BOOL) performLikeForItem:(DesignBaseClass*)item likeState:(BOOL) isLiked sender:(UIViewController*) sender  shouldUsePushDelegate:(BOOL) shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion
{
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        
        completion(NO);
        NO;
    }
    
    [[DesignsManager sharedInstance] likeDesign:item :isLiked :sender  :shouldUsePush withCompletionBlock:^ (id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([(BaseResponse*)serverResponse errorCode] == -1);
             if (isSuccess)
             {
                 //success
                 completion(YES);
             }
             else
             {
                 //fail
                 completion(NO);
             }
         }
         else
         {
             //fail
             completion(NO);
         }
     }];
    
    return YES;
}

- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion
{
    
    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        
        completion(NO);
        return;
    }
    
    [[UIManager sharedInstance] likePressedForItemId:itemId andItemType:itemType withState:isLiked sender:sender shouldUsePushDelegate:shouldUsePush withCompletionBlock:^(id serverResponse)
     {
         if (serverResponse != nil)
         {
             BOOL isSuccess = ([(BaseResponse*)serverResponse errorCode] == -1);
             if (isSuccess)
             {
                 //success
                 completion(YES);
             }
             else
             {
                 //fail
                 completion(NO);
             }
         }
         else
         {
             //fail
             completion(NO);
         }
     }];
}


#pragma mark - MyDesignEditProtocol

- (void)designPublishStateChanged:(NSString *)designId status:(DesignStatus)status
{
    [self.profileDesignsVC refreshContent];
}


+ (void) needToRefreshProfile :(BOOL) needUpdate
{
    bNeedToRefreshProfile = needUpdate;
}

#pragma mark - Actions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.shouldAlertCloseScreen)
    {
        [self closeScreen];
    }
}

- (IBAction)scrollToTopPressed:(id)sender
{
    if (self.currentPresentingPage != nil && [self.currentPresentingPage getContentVC] != nil )
        [[self.currentPresentingPage getContentVC] scrollToTop];
}

- (void)signOutPressed
{
    if ([[UserManager sharedInstance] isLoggedIn]) {
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"signout_confirm_alert", @"") delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"alert_msg_button_yes", @"") otherButtonTitles:NSLocalizedString(@"Nevermind", @""), nil];
        [alert setAccessibilityLabel:@"signout_confirm_alert"];
        [alert show];
    }
}

- (void)changePasswordPressed
{
    UIViewController* resetPasswordController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileResetPassword" inStoryboard:kNewProfileStoryboard];
    
    [self addChildViewController:resetPasswordController];
    [self.view addSubview:resetPasswordController.view];
    
    [self logFlurryEvent:FLURRY_PROFILE_EDIT_PASSWORD_CLICK];
}

- (void)closeScreen{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
