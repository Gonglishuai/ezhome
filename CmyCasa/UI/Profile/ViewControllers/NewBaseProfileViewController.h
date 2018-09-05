//
//  NewBaseProfileViewController.h
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import <UIKit/UIKit.h>

#import "NSObject+Flurry.h"
#import "UIViewController+Helpers.h"
#import "ProfessionalCell.h"
#import "FollowUserSingle.h"
#import "ArticleItemView.h"
#import "FindFriendsBaseViewController.h"
#import "ProfileInstanceBaseViewController.h"
#import "BaseActivityTableCell.h"
#import "ProfileUserDetailsViewController_iPad.h"
#import "ProfileProtocols.h"

@class MyDesignEditBaseViewController;
@class ProfilePageBaseViewController;
@class ProfileInstanceBaseViewController;
@class ProfileFollowingsViewController;
@class ProfileDesignsViewController;
@class ProfileFollowersViewController;
@class ProfileArticlesViewController;
@class ProfileProfessionalsViewController;
@class ProfileActivitiesViewController;
@class ProfileUserDetailsViewController_iPad;

typedef enum {
    LoadingStatusLoading = 0,
    LoadingStatusSuccess,
    LoadingStatusFailure,
    LoadingStatusDelayed
} LoadingStatuses;


//GAITrackedViewController
@interface NewBaseProfileViewController : UIViewController <DesignItemDelegate,
MyDesignEditDelegate,
FollowUserItemDelegate,
LikeDesignDelegate,
CommentDesignDelegate,
ActivityTableCellDelegate,
ProfessionalCellDelegate,
ArticleItemDelegate,
UITextFieldDelegate,
UITextViewDelegate,
PRofileMasterDelegate,
ProfileInstanceDataDelegate,
ProfileCountersDelegate,
ProfileUserDetailsDelegate>



// Actions
- (void)loadUserProfileAccordingToUserID;
- (IBAction)backPressed:(id)sender;
- (void)signOutPressed;
- (void)changePasswordPressed;
- (IBAction)scrollToTopPressed:(id)sender;
- (IBAction)openSettingsPressed:(id)sender;
- (void)startProfileEditingAfterRegistration;
- (BOOL)canLeaveCurrentScreen;
- (void)closeScreen;
- (BOOL)startMediaBrowse:(CGRect)rect;
+ (void)needToRefreshProfile :(BOOL) needUpdate;
- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion;
- (void)openGalleryFullScreen:(NSArray *)designs selectedDesignIdx:(NSInteger)selectedDesignIdx;

#pragma mark - New implementation

- (void)initDisplay;
- (void)updateDisplay;

// Init property
@property (strong, nonatomic)   NSString*           userId;
@property (weak, nonatomic)     id<ProfileDelegate> delegate;

// User Info
@property (strong, nonatomic) UserProfile*  userProfile;
@property (nonatomic, assign) BOOL isLoggedInUserProfile;
@property (nonatomic, assign) BOOL isShowSystemIcon;
// Loading status
@property (strong, nonatomic) NSMutableArray* loadingStatus;
@property (weak, nonatomic) IBOutlet UIView *ProfileMenuContainerView;
@property (weak, nonatomic) IBOutlet UIView *detailsViewContainer;
@property (nonatomic, strong) MyDesignDO *tempDesignPressed;

@property (nonatomic) ProfileTabs currentProfileTab;
@property (strong, nonatomic) MyDesignEditBaseViewController * editDesignViewController;
@property (nonatomic, strong) ProfileMasterBaseViewController *profileMenuController;
@property (nonatomic, strong) ProfileInstanceBaseViewController * currentPresentingPage;
@property (nonatomic, strong) ProfileFollowingsViewController * profileFollowingsVC;
@property (nonatomic, strong) ProfileDesignsViewController * profileDesignsVC;
@property (nonatomic, strong) ProfileFollowersViewController *profileFollersVC;
@property (nonatomic, strong) ProfileArticlesViewController *profileArticlesVC;
@property (nonatomic, strong) ProfileProfessionalsViewController *profileProfessionalsVC;
@property (nonatomic, strong) ProfileActivitiesViewController *profileActivitiesVC;
@property (nonatomic, strong) ProfileUserDetailsBaseViewController * profileUserDetailsVC;
@property (nonatomic, strong) ProfileUserDetailsBaseViewController * profileEditUserDetailsVC;
@property (nonatomic) BOOL profileEditRequestedAfterProfileLoad;
@end
