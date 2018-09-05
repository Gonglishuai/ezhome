//
//  NewProfileViewController-iPad.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "NewProfileViewController-iPad.h"
#import "MyDesignEditBaseViewController.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"
#import "ProfileDesignsViewController.h"
#import "ProfileProfessionalsViewController.h"
#import "ProfileArticlesViewController.h"
#import "ProfileFollowersViewController.h"
#import "ProfileFollowingsViewController.h"
#import "ProfileActivitiesViewController.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "ProfileUserDetailsBaseViewController.h"
#import "ProgressPopupViewController.h"
#import "SettingsViewController.h"

@interface NewProfileViewController_iPad ()

@property (nonatomic, strong) SettingsViewController* settingsViewController;
@property (weak, nonatomic) IBOutlet UIButton *systemBtn;

@end

@implementation NewProfileViewController_iPad

@synthesize profileFollowingsVC = _profileFollowingsVC;
@synthesize profileDesignsVC = _profileDesignsVC;
@synthesize profileFollersVC = _profileFollersVC;
@synthesize profileArticlesVC = _profileArticlesVC;
@synthesize profileProfessionalsVC = _profileProfessionalsVC;
@synthesize profileActivitiesVC = _profileActivitiesVC;


#pragma mark - Init
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markViewNeedsRefresh) name:kNotificationMyHomeDesignsNeedRefresh object:nil];

    [self initDisplay];
    
    self.systemBtn.hidden = self.isShowSystemIcon;
}

- (void)initDisplay
{
    [super initDisplay];
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    //1. init master menu-
    //Generate Profile Master Menu and Add it to Correct Context 
    self.profileMenuController=[ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileMasterVC"
                                                                              inStoryboard:kProfileStoryboard];


    self.profileMenuController.isLoggedInUserProfile=self.isLoggedInUserProfile;
    [self.ProfileMenuContainerView addSubview:self.profileMenuController.view];

    [self.profileMenuController initMasterMenuDisplay:self];


    self.ProfileMenuContainerView.hidden = YES;
    self.detailsViewContainer.hidden=YES;
    
    //Setup first Presenting Page
    
//    if (self.isLoggedInUserProfile) {
//        self.currentProfileTab=ProfileTabActivities;
//        [[self profileMenuController] setSelectedTab:self.currentProfileTab];
//        self.currentPresentingPage= self.profileActivitiesVC ;
//        self.currentPresentingPage.isLoggedInUserProfile=self.isLoggedInUserProfile;
//        
//    }else{
        self.currentProfileTab=ProfileTabDesign;
        [[self profileMenuController] setSelectedTab:self.currentProfileTab];
        self.currentPresentingPage= self.profileDesignsVC ;
        self.currentPresentingPage.isLoggedInUserProfile=self.isLoggedInUserProfile;
        
//    }
    //3. init default vc
    
    //4. Add default vc to screen
    [self.detailsViewContainer addSubview:self.currentPresentingPage.view];
    [self addChildViewController:self.currentPresentingPage];
    [self addChildViewController:self.profileMenuController];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadUserProfileAccordingToUserID];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc - NewProfileViewController_iPad");
}

#pragma mark- Profile page get selectors
-(ProfileDesignsViewController*)profileDesignsVC{
    
    if (_profileDesignsVC == nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                                          self.detailsViewContainer.frame.size.width,
                                          self.detailsViewContainer.frame.size.height);


        _profileDesignsVC = [[ProfileDesignsViewController alloc] initWithRect:profilePageRect];
        _profileDesignsVC.rootDesignDelegate = self;
        _profileDesignsVC.isLoggedInUserProfile = self.isLoggedInUserProfile;
        
        //TODO: refactor to base count when designs are paginated
        _profileDesignsVC.originalDataCount=self.userProfile.assets.count;
    }
    return _profileDesignsVC;
}

-(ProfileProfessionalsViewController*)profileProfessionalsVC {


    if (_profileProfessionalsVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                self.detailsViewContainer.frame.size.width,
                self.detailsViewContainer.frame.size.height);


        _profileProfessionalsVC=[[ProfileProfessionalsViewController alloc] initWithRect:profilePageRect];
        _profileProfessionalsVC.rootProfsDelegate=self;
        _profileProfessionalsVC.isLoggedInUserProfile=self.isLoggedInUserProfile;

        [_profileProfessionalsVC initContent];
    }
    return _profileProfessionalsVC;
}

-(ProfileArticlesViewController*)profileArticlesVC{

    if (_profileArticlesVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                self.detailsViewContainer.frame.size.width,
                self.detailsViewContainer.frame.size.height);


        _profileArticlesVC=[[ProfileArticlesViewController alloc] initWithRect:profilePageRect];
        _profileArticlesVC.rootArticlesDelegate =self;
        _profileArticlesVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        [_profileArticlesVC initContent];
    }
    return _profileArticlesVC;
}

-(ProfileFollowersViewController*)profileFollersVC{
    
    if (_profileFollersVC==Nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                                          self.detailsViewContainer.frame.size.width,
                                          self.detailsViewContainer.frame.size.height);

        _profileFollersVC=[[ProfileFollowersViewController alloc] initWithRect:profilePageRect];
        _profileFollersVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        _profileFollersVC.rootFollowDelegate=self;
        _profileFollersVC.originalDataCount=self.userProfile.followers;
        [_profileFollersVC initContent];
    }
    return _profileFollersVC;
}

-(ProfileFollowingsViewController*)profileFollowingsVC{
    
    if (_profileFollowingsVC==nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                                          self.detailsViewContainer.frame.size.width,
                                          self.detailsViewContainer.frame.size.height);

        _profileFollowingsVC=[[ProfileFollowingsViewController alloc] initWithRect:profilePageRect];
        _profileFollowingsVC.isLoggedInUserProfile=self.isLoggedInUserProfile;
        _profileFollowingsVC.originalDataCount=self.userProfile.following;
        _profileFollowingsVC.rootFollowDelegate=self;
        [_profileFollowingsVC initContent];
    }
    return _profileFollowingsVC;
}

-(ProfileActivitiesViewController*)profileActivitiesVC{
    
    if (_profileActivitiesVC==nil) {
        CGRect profilePageRect=CGRectMake(0, 0,
                                          self.detailsViewContainer.frame.size.width,
                                          self.detailsViewContainer.frame.size.height);
        
        _profileActivitiesVC=[[ProfileActivitiesViewController alloc] initWithRect:profilePageRect delegate:self];
        _profileActivitiesVC.isLoggedInUserProfile = self.isLoggedInUserProfile;
        [_profileActivitiesVC initContent];
    }
    return _profileActivitiesVC;
}

#pragma mark - Overrides

- (void)setUserProfile:(UserProfile *)currUserProfile
{
    [super setUserProfile:currUserProfile];

    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    //Master menu unhidden from base class
    self.detailsViewContainer.hidden=NO;
}

- (void)updateDisplay
{
    [super updateDisplay];
}

#pragma mark - Actions
- (IBAction)backPressed:(id)sender
{
    [super backPressed:sender];
}

- (IBAction)openSettingsPressed:(id)sender
{
    if(_settingsViewController == nil)
    {
        _settingsViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"settingsViewController" inStoryboard:kMainStoryBoard];
        _settingsViewController.vc = self;
    }else{
        
        if ([_settingsViewController parentViewController] == self) {
            [_settingsViewController.view removeFromSuperview];
            [_settingsViewController removeFromParentViewController];
        }else{
            if([[_settingsViewController view] superview]!=nil)
            {
                [_settingsViewController.view removeFromSuperview];
            }
        }
    }
    
    [self addChildViewController:_settingsViewController];
    _settingsViewController.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [self.view addSubview:_settingsViewController.view];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _settingsViewController.view.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [_settingsViewController startBgAnimation];
                     }];
}


- (void)closeScreen{
    [[UIMenuManager sharedInstance] updateMenuOptionSelectionIndex:kMenuOptionTypeNone];
    [super closeScreen];
}

- (void)refreshView
{
    [[ProgressPopupBaseViewController sharedInstance]  startLoading:self];
    [self loadUserProfileAccordingToUserID];

    [self updateDisplay];
}

- (void)markViewNeedsRefresh
{
    [NewBaseProfileViewController needToRefreshProfile :YES];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

#pragma mark- ProfileMasterDelegate
-(void)profileTabSelectionChange:(ProfileTabs)newTab{
    [super profileTabSelectionChange:newTab];
    
    //if we are in editing mode and base class didn't replace the profile tab, means we have something to save
    if([self.currentPresentingPage isEqual:self.profileEditUserDetailsVC] && self.currentProfileTab != newTab){

        if([self.profileEditUserDetailsVC changeExists])
        {
            return;
        }
    }

    if ([self.currentPresentingPage isEqual:self.profileUserDetailsVC]) {
        [self.profileUserDetailsVC initContent];
    }
    
    self.currentPresentingPage.isLoggedInUserProfile = self.isLoggedInUserProfile;
    
    //3. restore the selected vc
    [self.detailsViewContainer addSubview:self.currentPresentingPage.view];
  
    [self addChildViewController:self.currentPresentingPage];
    
    //For ipad only add back profile menu to childviewController
    [self addChildViewController:self.profileMenuController];

    [self.currentPresentingPage refreshContent];
}

-(void)findFriendsOpenAction{
    FindFriendsBaseViewController * ffc=  (FindFriendsBaseViewController*)[[UIManager sharedInstance] createUniversalFindFriends];
    [self addChildViewController:ffc];
    [self.view addSubview:ffc.view];
}

- (void)signOutPressed
{
    [super signOutPressed];
}

@end
