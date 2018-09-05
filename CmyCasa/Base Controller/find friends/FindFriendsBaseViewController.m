//
//  FindFriendsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsBaseViewController.h"
#import "UserBaseFriendDO.h"
#import "FindFriendCell.h"
#import "FindFriendsRO.h"
#import "SDWebImageManager.h"
#import "UserRO.h"
#import "NSString+EmailValidation.h"
#import "SocialFriendDO.h"
#import "AddrBookFriendsResponse.h"
#import "SocialFindFriendsResponse.h"
#import "iPadFindFriendsViewController.h"
#import "FFResultsViewController_iPhone.h"
#import <AddressBookUI/AddressBookUI.h>
#import "UserBaseFriendDO.h"
#import "FindFriendCell.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FindFriendsResultsBaseViewController.h"
#import "ProgressPopupViewController.h"

@interface FindFriendsBaseViewController ()


@property(nonatomic,strong)   NSCharacterSet *blockedCharacters;

@end

@implementation FindFriendsBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([ConfigManager isFindFriendsActive]) {
        [self.btnFindFacebookFriends setHidden:NO];
    }else{
        [self.btnFindFacebookFriends setHidden:YES];
    }
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_FIND_FRIEND_OPEN];
    }
#endif
    self.blockedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"&<>/\\\"'?+*%()$="];
   
    self.currentSearchMode=kFindModeAddressBook;
  	// Do any additional setup after loading the view.
    
    [self updateTranslations];
    
    _fim = [[FriendsInviterManager alloc] init];
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - FindFriendsBaseViewController");
}

- (void)updateTranslations {
    
    CGPoint titleCenter = self.lblFindFriendsTitle.center;
    self.lblFindFriendsTitle.text = NSLocalizedString(@"find_friends", @"");
    [self.lblFindFriendsTitle sizeToFit];
    self.lblFindFriendsTitle.center = titleCenter;

    [self.btnFindContactFriends setTitle:NSLocalizedString(@"find_contact_friends", @"") forState:UIControlStateNormal];
    [self.btnFindFacebookFriends setTitle:NSLocalizedString(@"find_facebook_friends", @"") forState:UIControlStateNormal];
    [self.btnFindFriendsByNameOrEmail setTitle:NSLocalizedString(@"find_by_name_or_email", @"") forState:UIControlStateNormal];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    return ([string rangeOfCharacterFromSet:self.blockedCharacters].location == NSNotFound);
}

-(void)refreshUIAfterSearch
{
    if (self.resultsController) {
        [self.resultsController setFim:_fim];
        [self.resultsController refreshUIAfterSearch];
    }
}

-(void)performSearchForAddressBook
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_FIND_FRIEND_GET_CONTACTS_FRIENDS];
    }
#endif
    
    [_fim searchAddressFriendsOnServerWithCompletion:^(id serverResponse, id error) {
        
        if (error) {
            [self performSearchErrorResponse:error];
        }else{
            AddrBookFriendsResponse* response=(AddrBookFriendsResponse*)serverResponse;
            if (response && response.errorCode==-1) {
                [self refreshUIAfterSearch];
            }else{
                
                [self performSearchErrorResponse:response.hsLocalErrorGuid];
            }
        }
        
        if (self.resultsController != nil)
        {
            [self.resultsController setLoading:NO];
        }
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        self.view.userInteractionEnabled=YES;
        
    } queue:dispatch_get_main_queue()];
}

-(void)performSearchforFreeText
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_FIND_FRIEND_SEARCH_ON_HS];
    }
#endif
    
    [_fim searchFreeText:self.searchField.text withCompletion:^(id serverResponse, id error) {
        
        AddrBookFriendsResponse* response=(AddrBookFriendsResponse*)serverResponse;
        if (error) {
          [self performSearchErrorResponse:error];
        }
        
        else if (response && response.errorCode==-1) {
            [self refreshUIAfterSearch];
            
            [self openInlineSearchResults];
        }else{
            [self performSearchErrorResponse:response.hsLocalErrorGuid];
        }

        if (self.resultsController != nil)
        {
            [self.resultsController setLoading:NO];
        }
        
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        self.view.userInteractionEnabled=YES;
        
    } queue:dispatch_get_main_queue()];
}

-(void)performSearchForFacebook
{
//#ifdef USE_FLURRY
//    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_FIND_FRIEND_GET_FACEBOOK_FRIENDS];
//    }
//#endif
//    
//    __block BOOL isLogedIn = NO;
//    
//    if(![FBSDKAccessToken currentAccessToken])
//    {
//        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//        [login
//         logInWithReadPermissions: @[@"public_profile", @"email"]
//         fromViewController:self
//         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//             if (error) {
//                 NSLog(@"Process error");
//             } else if (result.isCancelled) {
//                 NSLog(@"Cancelled");
//             } else {
//                 NSLog(@"Logged in");
//                 isLogedIn = YES;
//                 [self findFriends];
//             }
//         }];
//    }else{
//        isLogedIn = YES;
//        [self findFriends];
//    }
//    if (!isLogedIn) {
//        NSString * erMessage = NSLocalizedString(@"facebook_login_faile`d_msg", @"");
//        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_FAILED_FB_LOGIN] withPrevGuid:nil];
//        [self performSearchErrorResponse:errguid];
//    }
}

-(void)findFriends{
    
    self.view.userInteractionEnabled=NO;
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];

    [_fim searchFacebookFriendsWithCompletion:^(id serverResponse, id error) {
        
        SocialFindFriendsResponse* response = (SocialFindFriendsResponse*)serverResponse;
        if (error) {
            [self performSearchErrorResponse:error];
        } else if (response && response.errorCode==-1) {
            [self refreshUIAfterSearch];
        }
        
        if (self.resultsController != nil)
        {
            [self.resultsController setLoading:NO];
        }
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
        self.view.userInteractionEnabled=YES;

    } queue:dispatch_get_main_queue()];
}

-(void)performSearchOnServer
{
    [self.searchField resignFirstResponder];
    
    if (self.currentSearchMode==kFindModeAddressBook) {
       
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"nag_about_contact"]==nil) {
           
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ask_contact_access_title", @"") message:NSLocalizedString(@"ask_contact_access_body", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") otherButtonTitles:NSLocalizedString(@"ask_contact_access_allow", @""), nil] show];
            
            return;
        }
        
        
        [_fim checkForAddressBookAccessWithComplition:^(BOOL granted) {
            if (granted) {
                
                if (![_fim isUserHaveAddressBookContacts]) {
                    
                    [[[UIAlertView alloc] initWithTitle:@""
                                                message:NSLocalizedString(@"no_contacts_in_address_copy", @"") delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")  otherButtonTitles: nil] show];
                    return;
                }
                self.view.userInteractionEnabled=NO;
                [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];
                
                [self performSearchForAddressBook];
            }else{
                
                 [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"addressbook_access_denied_title", @"")
                                            message:[NSString stringWithFormat:NSLocalizedString(@"addressbook_access_denied", @""), [ConfigManager getAppName]]
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil] show];
            }
        } queue:dispatch_get_main_queue()];
    }
    
    if (self.currentSearchMode==kFindModeFreeText)
    {
        // check for string composite of only of empty spaces
        NSString *noSpacesString = [self.searchField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([self.searchField.text length]==0 || [noSpacesString length]==0) {
            return;
        }
        self.view.userInteractionEnabled=NO;
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];
        
        [self performSearchforFreeText];
    }

    if (self.currentSearchMode==kFindModeFacebook) {
        self.searchField.text = @"";
        [self performSearchForFacebook];
    }
}

-(void)performSearchErrorResponse:(NSString*)errorGUID{
}

- (IBAction)closeFindFriendsUI:(id)sender {
    
}

- (IBAction)freeTextSearchButtonAction:(id)sender {
    [self textFieldShouldReturn:self.searchField];
}

-(IBAction)getFacebookFriends:(id)sender{
    
    self.currentSearchMode=kFindModeFacebook;
    
    [self performSearchOnServer];
    
   
}

- (IBAction)showPicker:(id)sender
{
    
    self.currentSearchMode=kFindModeAddressBook;
    
    [self performSearchOnServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
 
}

#pragma mark- UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([self.searchField.text length]>=2) {
        self.currentSearchMode=kFindModeFreeText;
        self.lastContactSelected=[[UserBaseFriendDO alloc] init];
        self.lastContactSelected.currentStatus=kFriendUnknown;
        self.lastContactSelected.firstName=self.searchField.text;
        [self performSearchOnServer];
        self.resultsView.hidden=YES;
    }
    [self.searchField resignFirstResponder];
    return YES;
}

#pragma mark- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"no_contacts_in_address_copy", @"")]) {
        [self returnToInitialSearchState];
    }
    
    if ([[alertView message]isEqualToString:NSLocalizedString(@"ask_contact_access_body", @"")]) {
        switch (buttonIndex) {
            case 0:
            {
                [self returnToInitialSearchState];
            }
                break;
            case 1:
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"allow" forKey:@"nag_about_contact"];
                [self performSearchOnServer];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)returnToInitialSearchState{
    
}

-(void)openInlineSearchResults{
    
}

-(void)openNewSearchResults:(NSString *)title{
    
}

@end



