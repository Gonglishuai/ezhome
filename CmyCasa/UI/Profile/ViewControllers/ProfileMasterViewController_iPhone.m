//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProfileMasterViewController_iPhone.h"
#import "ProfilePagesMenuViewController_iPhone.h"
#import "ControllersFactory.h"
#import "NewBaseProfileViewController.h"

#define MasterViewSize       CGRectMake(0, 0, 320, self.currentProfileVc.isShowSystemIcon ? 180 : 200)
@interface ProfileMasterViewController_iPhone()
@property (weak, nonatomic) IBOutlet UILabel *myDesignsLabel;
@property (strong,nonatomic) NewBaseProfileViewController *currentProfileVc;

@end
@implementation ProfileMasterViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuController = [ControllersFactory instantiateViewControllerWithIdentifier:@"profilePagesMenuViewController" inStoryboard:kProfileStoryboard];
    [self.profileImage setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];

    self.menuController.ownerDelegate = self;
    self.menuController.isLoggedInUserProfile = self.isLoggedInUserProfile;
    self.currentProfileVc = (NewBaseProfileViewController *)self.ownerDelegate;
    self.myDesignsLabel.hidden = self.currentProfileVc.isShowSystemIcon;
}

-(void)refreshTableMenu{
    [self.menuController refreshTableMenu];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //update button lable
    [self.changePageButton setTitle:[self.menuController getTitleForTabCellNum:self.selectedTab] forState:UIControlStateNormal];
}

#pragma mark - Update UI
- (void)updateMasterMenuDisplay {
    [super updateMasterMenuDisplay];
    [self refreshTableMenu];
}

#pragma mark =
-(void)profileTabSelectionChange:(ProfileTabs)newTab{

    if(self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(profileTabSelectionChange:)])
    {
        self.selectedTab=newTab;
        [self.ownerDelegate profileTabSelectionChange:newTab];
    }
}

- (IBAction)openProfileOptionsMenu:(id)sender {
    
    [self.menuController selectRowForTab:self.selectedTab];
    if (self.ownerDelegate) {
        [self.menuController presentForContainer:(UIViewController*)self.ownerDelegate];
    }else{
        [self.menuController presentForContainer:self];
    }
}

#pragma mark -ProfileCountersDelegate
-(void)updateProfileCounterString:(NSString *)value ForTab:(ProfileTabs)tab{
    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(updateProfileCounterString:ForTab:)]) {
        [self.ownerDelegate updateProfileCounterString:value ForTab:tab];
    }
}

- (void)updateProfileCounter:(int)value ForTab:(ProfileTabs)tab{
    
    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]) {
        [self.ownerDelegate updateProfileCounter:value ForTab:tab];
    }
}

- (NSString *)getProfileCounterValueFor:(ProfileTabs)tab{
    
    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(getProfileCounterValueFor:)]) {
       return  [self.ownerDelegate getProfileCounterValueFor:tab];
    }
    
    return @"";
}

#pragma mark Overrides
- (IBAction)editProfileAction:(id)sender {

    if([[UserManager sharedInstance] isLoggedIn] == NO)
    {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_FOLLOW_USER, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
        //open signin dialog in profile base controller
        if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(openSignInDialog) ]) {
            [self.ownerDelegate openSignInDialog];
        }
        return;
    }
    //if profile page is currently logged in user, the open profile details
    if (self.isLoggedInUserProfile) {
        //other wise follow/unfollow
        if(self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(openProfilePageWithEditMode:)])
        {
            [self.ownerDelegate openProfilePageWithEditMode:YES];
        }
    }else{
        UIButton * btn=(UIButton*)sender;
        btn.selected = !btn.selected;
        [self updateFollowForViewedUserProfile:btn.selected];
    }
}

- (IBAction)opendUserProfileReadOnlyAction:(id)sender {

    if(self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(openProfilePageWithEditMode:)])
    {
        [self.ownerDelegate openProfilePageWithEditMode:NO];
    }
}

- (IBAction)openFollowingPage:(id)sender{
    [super openFollowingPage:sender];
}

- (IBAction)openFollowersPage:(id)sender{
    [super openFollowersPage:sender];
}

@end
