//
//  FFResultsViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "FindFriendsResultsBaseViewController.h"

@interface FFResultsViewController_iPhone : FindFriendsResultsBaseViewController

@property (weak, nonatomic) IBOutlet UIView *tableHolderView;

- (IBAction)navigateToSearch:(id)sender;
- (void)moveToInlineView;
@end
