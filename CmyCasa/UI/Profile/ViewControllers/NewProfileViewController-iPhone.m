//
//  NewProfileViewController-iPhone.m
//  Homestyler
//
//  Created by Yiftach Ringel on 24/06/13.
//  Modified by Sergei Berenson on 8/1/14
//

#import "NewProfileViewController-iPhone.h"
#import "MyDesignEditViewController_iPhone.h"
#import "ProfessionalPageViewController_iPhone.h"
#import "UILabel+Size.h"
#import "ProfessionalsResponse.h"
#import "ControllersFactory.h"
#import "ProfileProfessionalsViewController.h"
#import "ProfileArticlesViewController.h"
#import "ProfileFollowersViewController.h"
#import "ProfileFollowingsViewController.h"
#import "ProfileDesignsViewController.h"
#import "ProfileActivitiesViewController.h"
#import "ProfileUserDetailsBaseViewController.h"
#import "ProfileUserDetailsViewController_iPhone.h"
#import "ImageFetcher.h"
#import "ProgressPopupViewController.h"
#import "SettingsViewController_iPhone.h"

#define TABLE_VIEW_Y_START_POSITION 48
@interface NewProfileViewController_iPhone () < ProfileDelegate,UserLogInDelegate>
{
    __weak IBOutlet UIView *_topBarContainerView;
}

@property (nonatomic, weak) SettingsViewController_iPhone* settingsViewController;
@property (weak, nonatomic) IBOutlet UIButton *systemBtn;

@end

@implementation NewProfileViewController_iPhone

@synthesize profileFollowingsVC = _profileFollowingsVC;
@synthesize profileDesignsVC = _profileDesignsVC;
@synthesize profileFollersVC = _profileFollersVC;
@synthesize profileArticlesVC = _profileArticlesVC;
@synthesize profileProfessionalsVC = _profileProfessionalsVC;
@synthesize profileActivitiesVC = _profileActivitiesVC;

#pragma mark - Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initDisplay];
    
    [[ProgressPopupBaseViewController sharedInstance]  startLoading:self];

    self.systemBtn.hidden = self.isShowSystemIcon;
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadUserProfileAccordingToUserID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - NewProfileViewController_iPhone");
}

- (void)initDisplay
{
    //1. init master menu-
    //Generate Profile Master Menu and Add it to Correct Context
    self.profileMenuController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileMasterVC"
                                                                                inStoryboard:kProfileStoryboard];
    self.profileMenuController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 230);
    self.profileMenuController.isLoggedInUserProfile = self.isLoggedInUserProfile;
    [self.profileMenuController initMasterMenuDisplay:self];
    //Setup first Presenting Page
    //3. init default vc
//    if (self.isLoggedInUserProfile) {
//        [[self profileMenuController] setSelectedTab:ProfileTabActivities];
//        self.currentProfileTab = ProfileTabActivities;
//        self.currentPresentingPage = self.profileActivitiesVC ;
//        self.currentPresentingPage.isLoggedInUserProfile = self.isLoggedInUserProfile;
//    }else{
        [[self profileMenuController] setSelectedTab:ProfileTabDesign];
        self.currentProfileTab = ProfileTabDesign;
        self.currentPresentingPage = self.profileDesignsVC ;
        self.currentPresentingPage.isLoggedInUserProfile = self.isLoggedInUserProfile;
//    }

    //4. Add default vc to screen
    [self addChildViewController:self.currentPresentingPage];
    [self.view addSubview:self.currentPresentingPage.view];
    
    [self.currentPresentingPage insertTableViewHeader:self.profileMenuController];
    [self.currentPresentingPage.view setHidden:YES];
}


- (void)followPressed:(FollowUserInfo *)info didFollow:(BOOL)follow{
    [super followPressed:info didFollow:follow];
}

- (void)setUserProfile:(UserProfile *)currUserProfile
{
    [super setUserProfile:currUserProfile];
    [self.currentPresentingPage.view setHidden:NO];
    
    //update View heirarchy of top bar controlls.
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    
    [self.view bringSubviewToFront:_topBarContainerView];
}

#pragma mark- Profile page get selectors
-(ProfileDesignsViewController*)profileDesignsVC{
    
    if (_profileDesignsVC==Nil) {
        CGRect profilePageRect=[UIScreen mainScreen].bounds;
        _profileDesignsVC=[[ProfileDesignsViewController alloc] initWithRect:profilePageRect];
        _profileDesignsVC.rootDesignDelegate=self;
        _profileDesignsVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
    }
    return _profileDesignsVC;
}

-(ProfileProfessionalsViewController*)profileProfessionalsVC {
    
    if (_profileProfessionalsVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, TABLE_VIEW_Y_START_POSITION,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-TABLE_VIEW_Y_START_POSITION);
        
        
        _profileProfessionalsVC=[[ProfileProfessionalsViewController alloc] initWithRect:profilePageRect];
        _profileProfessionalsVC.rootProfsDelegate=self;
        _profileProfessionalsVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        [_profileProfessionalsVC initContent];
    }
    return _profileProfessionalsVC;
}

-(ProfileArticlesViewController*)profileArticlesVC{
    
    if (_profileArticlesVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, TABLE_VIEW_Y_START_POSITION,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-TABLE_VIEW_Y_START_POSITION);
        
        
        _profileArticlesVC=[[ProfileArticlesViewController alloc] initWithRect:profilePageRect];
        _profileArticlesVC.rootArticlesDelegate =self;
        _profileArticlesVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        [_profileArticlesVC initContent];
    }
    return _profileArticlesVC;
}

-(ProfileFollowersViewController*)profileFollersVC{
    
    if (_profileFollersVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, TABLE_VIEW_Y_START_POSITION,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-TABLE_VIEW_Y_START_POSITION);
        
        _profileFollersVC=[[ProfileFollowersViewController alloc] initWithRect:profilePageRect];
        _profileFollersVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        _profileFollersVC.rootFollowDelegate=self;
        [_profileFollersVC initContent];
    }
    return _profileFollersVC;
}

-(ProfileFollowingsViewController*)profileFollowingsVC{
    
    if (_profileFollowingsVC==nil) {
        CGRect profilePageRect=CGRectMake(0, TABLE_VIEW_Y_START_POSITION,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-TABLE_VIEW_Y_START_POSITION);
        
        _profileFollowingsVC=[[ProfileFollowingsViewController alloc] initWithRect:profilePageRect];
        _profileFollowingsVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        _profileFollowingsVC.rootFollowDelegate=self;
        [_profileFollowingsVC initContent];
    }
    return _profileFollowingsVC;
}

-(ProfileActivitiesViewController*)profileActivitiesVC
{
    if (_profileActivitiesVC==nil) {
        CGRect profilePageRect=CGRectMake(0, TABLE_VIEW_Y_START_POSITION,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height-TABLE_VIEW_Y_START_POSITION);
        
        _profileActivitiesVC=[[ProfileActivitiesViewController alloc] initWithRect:profilePageRect];
        _profileActivitiesVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        _profileActivitiesVC.rootActivityDelegate=self;
        [_profileActivitiesVC initContent];
    }
    return _profileActivitiesVC;
}

#pragma mark - Actions
- (void)closeScreen{
    
    [self.currentPresentingPage removeFromParentViewController];
    [self.currentPresentingPage.view removeFromSuperview];
    self.currentPresentingPage = nil;
    
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
    [super closeScreen];
}

- (IBAction)openSettingsPressed:(id)sender{

    if (_settingsViewController == nil) {
        _settingsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"SettingsViewController_iPhone" inStoryboard:kMainStoryBoard];
    }
    
    [self.navigationController pushViewController:_settingsViewController animated:YES];
}

#pragma mark- ProfileMasterDelegate

-(void)profileTabSelectionChange:(ProfileTabs)newTab{
    [super profileTabSelectionChange:newTab];
    
    self.currentPresentingPage.isLoggedInUserProfile = self.isLoggedInUserProfile;
    
    [self addChildViewController:self.currentPresentingPage];
    [self.view addSubview:self.currentPresentingPage.view];
    
    [self.currentPresentingPage insertTableViewHeader:self.profileMenuController];
    [self.currentPresentingPage refreshContent];
}

-(void)leaveProfileEditingWithoutChanges{
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.navigationController popViewControllerAnimated:YES];
                   });
}

- (void)professionalPressed:(NSString *)professionalId
{
    ProfessionalPageViewController_iPhone * ipv= [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    [[[AppCore sharedInstance] getProfsManager]getProffesionalByID:professionalId completionBlock:^(id serverResponse, id error) {
        
        if (!error) {

            ProfessionalsResponse * profData=(ProfessionalsResponse*)serverResponse;
            
            ipv.professional=profData.currentProfessional;
            
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            
            [self.navigationController pushViewController:ipv animated:YES];
        }
        
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        
    } queue:dispatch_get_main_queue()];
}

#pragma mark - ProfileDelegate
- (void)profileSignOutPressed{
    self.userProfile = nil;
    [self closeScreen];
}

-(void)signOutPressed{
    [super signOutPressed];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (void) loginRequestEndedwithState:(BOOL) state{
}

-(void)findFriendsOpenAction{
    
    FindFriendsBaseViewController * ffc = (FindFriendsBaseViewController*)[[UIManager sharedInstance] createUniversalFindFriends];
    [self.navigationController pushViewController:ffc animated:YES];
}

- (void)askToLeaveWithoutSave {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openProfilePageWithEditMode:(BOOL)isEdit{
    
    self.profileEditUserDetailsVC =[ControllersFactory instantiateViewControllerWithIdentifier:@"profileUserDetailsViewController" inStoryboard:kProfileStoryboard];
    self.profileEditUserDetailsVC.isLoggedInUserProfile = self.isLoggedInUserProfile;
    self.profileEditUserDetailsVC.rootUserDelegate = self;

    if(isEdit){
        self.profileEditUserDetailsVC.isEditingPresentation=YES;
    }
    
    [self.navigationController pushViewController:self.profileEditUserDetailsVC animated:YES];
}

- (void)changePasswordPressed
{
    UIViewController* resetPasswordController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileResetPassword" inStoryboard:kNewProfileStoryboard];
    
    [self logFlurryEvent:FLURRY_PROFILE_EDIT_PASSWORD_CLICK];
    [self presentViewController:resetPasswordController animated:YES completion:nil];
}
@end
