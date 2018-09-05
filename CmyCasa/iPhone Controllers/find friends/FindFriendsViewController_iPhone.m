//
//  iphoneFindFriendsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsViewController_iPhone.h"
#import "FFResultsViewController_iPhone.h"
#import "FriendsInviterManager.h"
#import "ControllersFactory.h"

@interface FindFriendsViewController_iPhone ()

@end

@implementation FindFriendsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.scrollViewFF.contentSize = CGSizeMake(self.scrollViewFF.frame.size.width, self.scrollViewFF.frame.size.height);
    
    if (!IS_IPAD && !IS_PHONEPOD5()) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:NO];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)dealloc{
    NSLog(@"dealloc - FindFriendsViewController_iPhone");
}

#pragma mark-  Override
- (IBAction)closeFindFriendsUI:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshUIAfterSearch{
    [super refreshUIAfterSearch];
    if (self.iphResults) {
        [self.iphResults refreshUIAfterSearch];
    }
}

-(void)openInlineSearchResults{
    [self openNewSearchResults:@""];
}

-(void)openNewSearchResults:(NSString*)title{
   
    [self.resultsView setHidden:YES ];
    
    self.iphResults = [ControllersFactory instantiateViewControllerWithIdentifier:@"ffResultsViewController" inStoryboard:kNewProfileStoryboard];
  
    self.iphResults.currentSearchMode = self.currentSearchMode;
  
    [self.navigationController pushViewController:self.iphResults animated:YES];

    [self.iphResults setLoading:YES];

    if ([self.searchField.text length]>0 && self.currentSearchMode==kFindModeFreeText) {
        self.iphResults.searchField.text=self.searchField.text;
        self.iphResults.searchText=self.searchField.text;
    }else{
          self.iphResults.searchField.text=@"";
          self.iphResults.searchText=@"";
    }
}

-(IBAction)getFacebookFriends:(id)sender{
    [self.fim resetSearchResults];
    
    self.currentSearchMode = kFindModeFacebook;
    
    [self openNewSearchResults:NSLocalizedString(@"find_friends_results_title_facebook", @"")];
    
    [self performSearchOnServer];
}

-(void)performSearchErrorResponse:(NSString*)errorGUID{
    //TODO: place different alert for facebook friends
    
    NSString * msg=[[HSErrorsManager sharedInstance] getErrorByGuidLocalized:errorGUID];
    
    if (msg==nil) {
        msg=NSLocalizedString(@"sorry_search_friend_failed", @"");
    }
    [[[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.iphResults navigateToSearch:nil];
    });
}

- (IBAction)showPicker:(id)sender
{
    [self.fim resetSearchResults];
    self.currentSearchMode=kFindModeAddressBook;
    [self openNewSearchResults:NSLocalizedString(@"find_friends_results_title_addrbook", @"")];
    
    [self performSearchOnServer];
}

-(void)returnToInitialSearchState{
    
    if (self.iphResults) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.iphResults navigateToSearch:nil];
                       });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Keyboard notificaitons

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    [self.scrollViewFF setContentOffset:CGPointMake(0, 50) animated:YES];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification{
    [self.scrollViewFF setContentOffset:CGPointZero animated:YES];
}

@end



