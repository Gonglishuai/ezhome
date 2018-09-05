//
//  FindFriendsResultsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import <UIKit/UIKit.h>
#import "FindFriendCell.h"
#import "FriendsInviterManager.h"
//#import "FBSDKGameRequestDialog.h"


//FBSDKAppInviteDialogDelegate
@interface FindFriendsResultsBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FindFriendActionsDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIView *resultsSearchView;
@property (weak, nonatomic) IBOutlet UIView *topNavigation;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *resultsTable;
@property (strong, nonatomic) NSString * searchText;
@property (nonatomic) FindFriendMode currentSearchMode;
@property(nonatomic, strong) FriendsInviterManager * fim;


- (void)refreshUIAfterSearch;
- (void)moveToInlineView;
- (void)moveToNewView;
- (void)setLoading:(BOOL)isLoading;
- (IBAction)freeTextSearchActionButton:(id)sender;

@end
