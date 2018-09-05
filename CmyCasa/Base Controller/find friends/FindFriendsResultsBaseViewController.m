//
//  FindFriendsResultsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "FindFriendsResultsBaseViewController.h"
#import "FindFriendCell.h"
#import "UserRO.h"
#import "SocialFriendDO.h"
#import "AddrBookFriendDO.h"
#import "NSString+EmailValidation.h"
#import "NewBaseProfileViewController.h"
#import "AddrBookFriendsResponse.h"
#import "SocialFindFriendsResponse.h"
#import "UILabel+Size.h"
#import "ControllersFactory.h"
#import "ProgressPopupViewController.h"

@interface FindFriendsResultsBaseViewController ()
{
    CGRect _rectOriginalNoResultsLabel;
}

@property(nonatomic, weak) NSCharacterSet *blockedCharacters;
@property(nonatomic, weak) UserBaseFriendDO * tempInvitedFriend;
-(void)performSearchforFreeText;
-(void)createInvitationEmail:(UserBaseFriendDO*)tempFriend;

@end

@implementation FindFriendsResultsBaseViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - FindFriendsResultsBaseViewController");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.currentSearchMode == kFindModeFreeText) {
        self.noResultsLabel.text=[NSString stringWithFormat:NSLocalizedString(@"find_friends_no_results_copy", @""),[ConfigManager getAppName],[ConfigManager getAppName]];
    }else{
        self.noResultsLabel.text=NSLocalizedString(@"find_friends_no_results_filter_copy", @"");
    }
    
    self.noResultsLabel.hidden = YES;
    
    CGSize sz=[self.noResultsLabel getActualTextHeightForLabel:100];
    CGRect frm=self.noResultsLabel.frame;
    frm.size.height=sz.height;
    self.noResultsLabel.frame=frm;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.resultsTable reloadData];
}

-(void)performSearchforFreeText{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_FIND_FRIEND_SEARCH_ON_HS];
    }
#endif

    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    self.view.userInteractionEnabled=NO;
    [_fim searchFreeText:self.searchField.text withCompletion:^(id serverResponse, id error) {
        
        AddrBookFriendsResponse* response=(AddrBookFriendsResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [self refreshUIAfterSearch];

        }else{
            
            [[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"sorry_search_friend_failed", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
        }
        
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        self.view.userInteractionEnabled=YES;
        
    } queue:dispatch_get_main_queue()];
}

-(void)refreshUIAfterSearch{

    [self.resultsTable reloadData];
    NSString * filter=@"";
    if (self.currentSearchMode!=kFindModeFreeText) {
        filter=self.searchText;
    }
}

- (void)setLoading:(BOOL)isLoading
{
    if (CGRectIsEmpty(_rectOriginalNoResultsLabel))
    {
        _rectOriginalNoResultsLabel = self.noResultsLabel.frame;
    }
    
    if (isLoading)
    {
        self.noResultsLabel.frame = CGRectMake([UIScreen currentScreenBoundsDependOnOrientation].size.width, self.noResultsLabel.frame.origin.y, self.noResultsLabel.frame.size.width, self.noResultsLabel.frame.size.height);
        self.resultsTable.hidden = YES;
    }
    else
    {
        self.noResultsLabel.frame = _rectOriginalNoResultsLabel;
        self.resultsTable.hidden = NO;
    }
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (IS_IPHONE) ? 112 : 74; //returns floating point which will be used for a cell row height at specified row index
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    NSUInteger count = [[[_fim searchResults]allKeys]count];
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSString * filter=@"";
    if (self.currentSearchMode!=kFindModeFreeText) {
        filter=self.searchText;
    }
    NSArray * result = [[_fim getSearchResultsForSection:section withFilter:filter] copy];
    
	return [result count];
    
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    
    FindFriendCell * cell = (FindFriendCell*)[self.resultsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSString * filter=@"";
    if (self.currentSearchMode!=kFindModeFreeText) {
        filter=self.searchText;
    }
    
    NSArray * result = [[_fim getSearchResultsForSection:indexPath.section withFilter:filter] copy];
    
    if (indexPath.row < [result count]) {
        UserBaseFriendDO *bfriend = [result objectAtIndex:indexPath.row];
        cell.delegate=self;
        [cell initWithFriendData:bfriend];
    }
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma mark- FindFriendActionDelegate

-(void)findFriendPerfomAction:(UserBaseFriendDO*)bfriend{
   [self.searchField resignFirstResponder]; 
    
    if (bfriend.currentStatus==kFriendHSFollowing) {
        //unfollow
    }
    if (bfriend.currentStatus==kFriendHSNotFollowing) {
        //unfollow
        self.view.userInteractionEnabled=NO;
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];
    
        [[HomeManager sharedInstance] followUser:bfriend._id follow:YES withCompletion:^(id serverResponse) {
            
            bfriend.currentStatus=kFriendHSFollowing;
            //update local cache of followings
            [[HomeManager sharedInstance] addFollowingUserFromFriend:bfriend];
            
            self.view.userInteractionEnabled=YES;
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
            [[NSNotificationCenter defaultCenter] postNotificationName:FFFollowStatusChangedNotification object:nil];
            DISPATCH_ASYNC_ON_MAIN_QUEUE([[self resultsTable] reloadData]);
            
        } failureBlock:^(NSError *error) {
            self.view.userInteractionEnabled=YES;
            [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        } queue:dispatch_get_main_queue()];
    }
    
    if (bfriend.currentStatus==kFriendNotHomestyler) {
        if (bfriend.isFacebookFriend) {
            SocialFriendDO * sfriend=(SocialFriendDO*)bfriend;
            //open Hs invite mechanism
            self.tempInvitedFriend = sfriend;
            
#ifdef USE_FLURRY
            if(ANALYTICS_ENABLED){
//                [HSFlurry logEvent:FLURRY_FIND_FRIEND_INVITE_FB_OPEN];
            }
#endif
            
//            FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
//            content.appLinkURL = [NSURL URLWithString:@"https://fb.me/10154377750886100"];
//
//            // Present the dialog. Assumes self is a view controller
//            // which implements the protocol `FBSDKAppInviteDialogDelegate`.
//            [FBSDKAppInviteDialog showFromViewController:self
//                                             withContent:content
//                                                delegate:self];
        }
        
        if (bfriend.isFacebookFriend==NO) {//means he contact
            
            if ([bfriend.email length]>0 && [bfriend.email isStringValidEmail]) {
                //open mail sharing
                self.tempInvitedFriend=bfriend;
                [self createInvitationEmail:bfriend];
            }else{
                //show alert about missing/wrong email
                
                [[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"invite_email_friend_no_email", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
            }
        }
    }
}

-(void)findFriendProfileClickAction:(UserBaseFriendDO*)bfriend{
    [self.searchField resignFirstResponder];
    if (bfriend._id==nil) {
        return;
    }
    NSLog(@"%@",bfriend._id);
    
    NewBaseProfileViewController* profileViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfileViewController" inStoryboard:kNewProfileStoryboard];
    
    [profileViewController setUserId:bfriend._id];
    
    [[[UIManager sharedInstance] pushDelegate].navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark- Email Composing
-(void)createInvitationEmail:(UserBaseFriendDO*)tempFriend{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        //TODO: REPLACE TO REAL EMAIL CONTENT
        NSString * subjectPost = [NSString stringWithFormat:NSLocalizedString(@"invite_friend_email_subject",@""), [ConfigManager getAppName]];
        
        NSString * body = [NSString stringWithFormat:NSLocalizedString(@"invite_friend_email_body",@"check out this design..."), [ConfigManager getAppName]];
        
        NSString* link= [[[[[ConfigManager sharedInstance] getMainConfigDict]objectForKey:@"share"] objectForKey:@"url"] objectForKey:@"link"];
        body=[body stringByReplacingOccurrencesOfString:@"{{url}}" withString:link];
        body=[body stringByReplacingOccurrencesOfString:@"{{title_url}}" withString:link];
        
        [mailViewController setSubject:subjectPost];
        [mailViewController setMessageBody:body isHTML:YES];
        [mailViewController setToRecipients:[NSArray arrayWithObject:tempFriend.email]];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self  presentViewController:mailViewController animated:YES completion:nil];
        });
        
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:FLURRY_FIND_FRIEND_INVITE_EMAIL_OPEN];
        }
#endif
    }else {
        
        HSMDebugLog(@"Device is unable to send email in its current state.");
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:NSLocalizedString(@"email_missing_default_msg",@"")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                          otherButtonTitles: nil]show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    if(result	!=	MFMailComposeResultCancelled)
    {
        
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){     
            
//            [HSFlurry logEvent:FLURRY_FIND_FRIEND_INVITE_EMAIL_SUCCESS];
            
        }
#endif
        if (self.tempInvitedFriend) {
            self.tempInvitedFriend.currentStatus=kFriendInvited;
        
        [_fim inviteFriendToJoinHomestylerViaEmail:self.tempInvitedFriend.email
                                    withCompletion:^(id serverResponse, id error) {
            
        } queue:dispatch_get_main_queue()];
      }
    }
    
    [self refreshUIAfterSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)performSearch{
    //check if server side call needed or filter
    
    if (self.currentSearchMode==kFindModeFreeText) {
        //perform new server search
        if ([self.searchField.text length]>1) {
             [self performSearchforFreeText];
        }
       
        return;
    }
    
    if (self.currentSearchMode==kFindModeAddressBook || self.currentSearchMode==kFindModeFacebook) {
        //perform filter
        [self refreshUIAfterSearch];
        return;
    }
}

#pragma mark- UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    [self performSearch];
    [self.searchField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (![string isEqualToString:@"\n"]) {
        if ([string length]==0) {
            NSUInteger size = [self.searchField.text length];
            if (size<1) {
                size=1;
            }
            self.searchText=[self.searchField.text substringToIndex:size-1];
            
        }else{
            self.searchText=[NSString stringWithFormat:@"%@%@",self.searchField.text,string];
        }
    }
    if(self.currentSearchMode!=kFindModeFreeText)
    {
        [self performSearch];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    self.searchText = @"";
    if(self.currentSearchMode!=kFindModeFreeText)
    {
        [self performSearch];
    }
    return YES;
}

- (IBAction)freeTextSearchActionButton:(id)sender {
    [self textFieldShouldReturn:self.searchField];
}

- (void)moveToInlineView{
    //implemented in son's DO NOT Delete!!!
}

- (void)moveToNewView{
    //implemented in son's DO NOT Delete!!!
}

//- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
//    [[[UIAlertView alloc] initWithTitle:@""
//                                message:NSLocalizedString(@"invite_fb_friend_success", @"")
//                               delegate:nil
//                      cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
//    self.tempInvitedFriend.currentStatus = kFriendInvited;
//
//    SocialFriendDO * sfriend = (SocialFriendDO*)self.tempInvitedFriend;
//
//    [_fim inviteFriendToJoinHomestylerViaFacebook:sfriend.socialId
//                                   withCompletion:^(id serverResponse, id error)
//    {
//        
//        [self refreshUIAfterSearch];
//        
//#ifdef USE_FLURRY
//        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent:FLURRY_FIND_FRIEND_INVITE_FB_SUCCESS];
//        }
//#endif
//
//    } queue:dispatch_get_main_queue()];
//}

//- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
//
//    NSString * erMessage = [error localizedDescription];
//
//    [[[UIAlertView alloc]initWithTitle:@""
//                               message:erMessage
//                              delegate:nil
//                     cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"")
//                     otherButtonTitles: nil] show];
//
//}

@end
