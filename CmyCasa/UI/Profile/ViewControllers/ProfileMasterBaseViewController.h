//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProfileProtocols.h"

@protocol FollowUserItemDelegate;
@protocol ProfileCountersDelegate;

//Profile Tabs
#define TABS_NUMBER_OF_TABS                 4
#define TABS_TITLE_ACTIVITY                 NSLocalizedString(@"Activity_title", @"")
#define TABS_TITLE_MY_DESIGNS               NSLocalizedString(@"profile_tab_my_design", @"")
#define TABS_TITLE_OTHER_DESIGNS            NSLocalizedString(@"profile_tab_design", @"")
#define TABS_TITLE_FOLLOWERS                NSLocalizedString(@"profile_tab_followers", @"")
#define TABS_TITLE_FOLLOWING                NSLocalizedString(@"profile_tab_following", @"")
#define TABS_TITLE_HEARTED_ARTICLES         NSLocalizedString(@"profile_tab_articles", @"")
#define TABS_TITLE_FOLLOWED_PROFFESIONALS   NSLocalizedString(@"profile_tab_professionals", @"")

@protocol PRofileMasterDelegate <NSObject>
@optional
-(void)profileTabSelectionChange:(ProfileTabs)newTab;
-(void)openProfilePageWithEditMode:(BOOL)isEdit;
-(void)findFriendsOpenAction;
-(void)openSignInDialog;
@end

@interface ProfileMasterBaseViewController : UIViewController

@property (nonatomic) ProfileTabs selectedTab;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingsCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *profileViews;
@property (weak, nonatomic) IBOutlet UILabel *locationIcon;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingsButton;
@property (weak, nonatomic) IBOutlet UILabel *readMoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UIButton *findFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionText;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (nonatomic) BOOL isLoggedInUserProfile;
@property (nonatomic,weak) id<PRofileMasterDelegate,FollowUserItemDelegate,ProfileCountersDelegate> ownerDelegate;
@property (strong, nonatomic) UserProfile*  userProfile;

- (void)openDesignsTab;
- (void)openActivityTab;
- (IBAction)openFollowingPage:(id)sender;
- (IBAction)openFollowersPage:(id)sender;
- (void)initMasterMenuDisplay:(id<PRofileMasterDelegate,FollowUserItemDelegate,ProfileCountersDelegate>)delegate;
- (void)updateMasterMenuDisplay;
- (void)setUserProfile:(UserProfile *)currUserProfile isReadOnlyProfile:(BOOL)readOnly;
- (IBAction)editProfileAction:(id)sender;
- (IBAction)findFriendsAction:(id)sender;
- (IBAction)opendUserProfileReadOnlyAction:(id)sender;
- (void)activatePageSelection:(ProfileTabs)indexPathTab;
- (void)updateFollowForViewedUserProfile:(BOOL)follow;

@end