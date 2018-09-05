//
//  iPadFindFriendsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsBaseViewController.h"
#define MIN_FIND_HEIGHT_CONTAINER 345
#define MAX_NUMBER_OF_ROWS_TO_EXAPND_UI 3
#define NUMBER_OF_ROWS_DELTA_PIXELS 37
#define ROW_HEIGHT_FOR_EXAND_UI 90
@interface iPadFindFriendsViewController : FindFriendsBaseViewController

@property (weak, nonatomic) IBOutlet UIView *topbarView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIView *outerResultsController;
@property (weak, nonatomic) IBOutlet UIView *outerTableHolder;
- (IBAction)navigateBackToSearch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *resultsTypeTitle;

@end
