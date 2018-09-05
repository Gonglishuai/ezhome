//
//  FindFriendsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import <UIKit/UIKit.h>
#import "FindFriendsResultsBaseViewController.h"
#import "FriendsInviterManager.h"


@class AddressBookUI;
@class UserBaseFriendDO;
@class FindFriendCell;
@class MessageUI;
@class MFMailComposeViewController;

static NSString *const FFFollowStatusChangedNotification = @"FFFollowStatusChangedNotification";

@interface FindFriendsBaseViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnFindFriendsByNameOrEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnFindFacebookFriends;
@property (weak, nonatomic) IBOutlet UIButton *btnFindContactFriends;
@property (weak, nonatomic) IBOutlet UILabel *lblFindFriendsTitle;
@property (weak, nonatomic) IBOutlet UIView *findMainContainer;
@property (weak, nonatomic) IBOutlet UIView *resultsView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (nonatomic)FindFriendMode currentSearchMode;
@property (nonatomic,strong) UserBaseFriendDO * lastContactSelected;
@property (nonatomic,strong) FriendsInviterManager * fim;
@property (nonatomic,strong) UIPopoverController * contactsPopover;
@property (nonatomic,strong) ABPeoplePickerNavigationController *addPersonViewController;
@property (nonatomic,strong) FindFriendsResultsBaseViewController * resultsController;

- (IBAction)closeFindFriendsUI:(id)sender;
- (void)performSearchErrorResponse:(NSString*)errorGUID;
- (IBAction)freeTextSearchButtonAction:(id)sender;
- (IBAction)getFacebookFriends:(id)sender;
- (void)refreshUIAfterSearch;
- (void)openInlineSearchResults;
- (void)openNewSearchResults:(NSString*)title;
- (IBAction)showPicker:(id)sender;
- (void)returnToInitialSearchState;
- (void)performSearchForAddressBook;
- (void)performSearchforFreeText;
- (void)performSearchForFacebook;
- (void)performSearchOnServer;
@end

