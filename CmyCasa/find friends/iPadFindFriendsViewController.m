 //
//  iPadFindFriendsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "iPadFindFriendsViewController.h"
#import "FriendsInviterManager.h"
#import "ControllersFactory.h"

@implementation iPadFindFriendsViewController

-(void)dealloc{
    NSLog(@"dealloc - iPadFindFriendsViewController");
}


#pragma mark-  Override
- (IBAction)closeFindFriendsUI:(id)sender {
    if([[self view] superview]!=nil)
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

-(void)refreshUIAfterSearch{
    [super refreshUIAfterSearch];
}

-(void)openInlineSearchResults{
    //1. Check number of results
    NSInteger totalResults = [self.fim getNumberOfResultsFlat];
    
    //2. calculate new ui height
    
    int newHeightDelta = (int) MIN(totalResults,MAX_NUMBER_OF_ROWS_TO_EXAPND_UI );
    
    if (newHeightDelta==0) {
        newHeightDelta=1;
    }
    if (newHeightDelta>0) {
        newHeightDelta=(newHeightDelta*ROW_HEIGHT_FOR_EXAND_UI)+NUMBER_OF_ROWS_DELTA_PIXELS;
    }
    
    CGRect mainFrame=self.findMainContainer.frame;
    
    mainFrame.size.height=MIN_FIND_HEIGHT_CONTAINER+newHeightDelta;
    //  mainFrame.origin.y=(self.view.bounds.size.height-mainFrame.size.height)/2;
    self.findMainContainer.frame=mainFrame;
    
   // BOOL shouldHide= [[[[FriendsInviterManager sharedInstance]searchResults]allKeys]count]==0;
    [self.resultsView setHidden:NO ];
    
    if (!self.resultsController) {
        self.resultsController=[ControllersFactory instantiateViewControllerWithIdentifier:@"ffResultsViewController" inStoryboard:kNewProfileStoryboard];
    }else{
        [self.resultsController removeFromParentViewController];
        [self.resultsController.view removeFromSuperview];
    }
    
    CGRect resultsFrame=self.resultsController.view.frame;
    
    resultsFrame.size=self.resultsView.frame.size;
    self.resultsController.view.frame=resultsFrame;
    
    
    [self.resultsController moveToInlineView];
    self.resultsController.searchField.text=@"";
    self.resultsController.searchText=@"";
    self.resultsController.currentSearchMode=self.currentSearchMode;
    
    [self.resultsView addSubview:self.resultsController.view];
    [self addChildViewController:self.resultsController];
    [self.resultsController refreshUIAfterSearch];
}

-(void)openNewSearchResults:(NSString*)title{
    
    CGPoint titleCenter = self.resultsTypeTitle.center;
    self.resultsTypeTitle.text = title;
    [self.resultsTypeTitle sizeToFit];
    self.resultsTypeTitle.center = titleCenter;
    
    
    CGRect mainFrame=self.findMainContainer.frame;
    
    mainFrame.size.height=MIN_FIND_HEIGHT_CONTAINER;
   
    self.findMainContainer.frame=mainFrame;
    [self.resultsView setHidden:YES ];
     self.findMainContainer.hidden=YES;
    self.outerResultsController.hidden=NO;
    
    if (!self.resultsController) {
        self.resultsController=[ControllersFactory instantiateViewControllerWithIdentifier:@"ffResultsViewController" inStoryboard:kNewProfileStoryboard];
    }else{
        [self.resultsController removeFromParentViewController];
        [self.resultsController.view removeFromSuperview];
    }
    
    CGRect resultsFrame = self.resultsController.view.frame;
    resultsFrame.size = self.outerTableHolder.frame.size;
    self.resultsController.view.frame = resultsFrame;
    self.resultsController.searchField.text=@"";
    self.resultsController.searchText=@"";
    self.resultsController.currentSearchMode=self.currentSearchMode;
  
   
    [self.resultsController moveToNewView];
    [self.outerTableHolder addSubview:self.resultsController.view];
    [self addChildViewController:self.resultsController];
    
    [self.resultsController setLoading:YES];
}

-(IBAction)getFacebookFriends:(id)sender{
    
    self.currentSearchMode=kFindModeFacebook;
    [self openNewSearchResults:NSLocalizedString(@"find_friends_results_title_facebook", @"")];
  
    [self performSearchOnServer];
}

-(void)performSearchErrorResponse:(NSString*)errorGUID{
    //TODO: place different alert for facebook friends
    
    
    NSString * msg=[[HSErrorsManager sharedInstance] getErrorByGuidLocalized:errorGUID];
    
    if (msg==nil) {
        msg=NSLocalizedString(@"sorry_search_friend_failed", @"");
    }

    
    [[[UIAlertView alloc]initWithTitle:@"" message:msg
                              delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
    

        [self navigateBackToSearch:nil];
}

- (IBAction)showPicker:(id)sender
{
    self.currentSearchMode=kFindModeAddressBook;
    
    [self openNewSearchResults:NSLocalizedString(@"find_friends_results_title_addrbook", @"")];
    
    [self performSearchOnServer];
}

- (IBAction)navigateBackToSearch:(id)sender {
    
    self.outerResultsController.hidden=YES;
    if (self.resultsController) {
        [self.resultsController removeFromParentViewController];
        [self.resultsController.view removeFromSuperview];
        self.resultsController.searchField.text=@"";
       self.resultsController.searchText=@"";
    }

    CGRect mainFrame=self.findMainContainer.frame;
    
    mainFrame.size.height=MIN_FIND_HEIGHT_CONTAINER;
    
    self.findMainContainer.frame=mainFrame;
    [self.resultsView setHidden:YES ];
    self.findMainContainer.hidden=NO;
    self.outerResultsController.hidden=YES;
}

-(void)returnToInitialSearchState{
    
    [self navigateBackToSearch:nil];
}

@end
