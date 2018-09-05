//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProfileMasterBaseViewController.h"
#import "FollowUserSingle.h"
#import "UserExtendedDetails.h"
#import "UILabel+Size.h"
#import "ImageFetcher.h"
#import "UIButton+NUI.h"
#import "UILabel+NUI.h"
#import "UIImageView+WebCache.h"
#import "DataManager.h"

#define PROFILE_MENU_SELECTION_COLOR_PRESS ([UIColor colorWithRed:159.0f/255.f green:228.0f/255.f blue:1.0f/255.f alpha:1.0f])
#define PROFILE_MENU_SELECTION_COLOR_UNPRESS ([UIColor colorWithRed:0.0f/255.f green:127.0f/255.f blue:234.0f/255.f alpha:1.0f])
#define kLocationLabelLeftOffset 8

@implementation ProfileMasterBaseViewController {

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)initMasterMenuDisplay:(id<PRofileMasterDelegate,FollowUserItemDelegate,ProfileCountersDelegate>)delegate {
    self.ownerDelegate = delegate;
}

- (void)updateMasterMenuDisplay {

    if (!self.userProfile.userDescription || self.userProfile.userDescription.length==0)
    {
        self.descriptionText.text = @"";
        self.readMoreLabel.hidden=YES;
    }else{
        self.readMoreLabel.hidden=NO;
         self.descriptionText.text = self.userProfile.userDescription;
        
        if (IS_IPAD) {
            CGSize size=[self.descriptionText getActualTextHeightForLabel:63];
            
            CGRect rect=self.descriptionText.frame;
            
            rect.size=CGSizeMake(rect.size.width, size.height);
            self.descriptionText.frame = rect;
            
            self.readMoreLabel.frame = CGRectMake(self.readMoreLabel.frame.origin.x,
                                                self.descriptionText.frame.origin.y + self.descriptionText.frame.size.height+3,
                                                self.readMoreLabel.frame.size.width,
                                                self.readMoreLabel.frame.size.height);
        }
    }

    if (![[UserManager sharedInstance] isUserInfoExists]) {
        NSMutableString* phone = [[[UserManager sharedInstance] currentUser].userPhone mutableCopy];
        if ([phone length] > 0)
        {
            NSUInteger total = [phone length];
            float star = ceil(total / 3.0);
            
            [phone replaceCharactersInRange:NSMakeRange(total-star*2, star) withString:@"****"];
            self.nameLabel.text = phone;
        }
    }

    if ([self.userProfile.firstName length] >0 || [self.userProfile.lastName length] > 0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.userProfile.firstName, self.userProfile.lastName];
    }
    
    CGSize designSize = self.profileImage.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.userProfile.userPhoto)?self.userProfile.userPhoto:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.profileImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:_profileImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (image != nil)
                                          {
                                              _profileImage.image = image;
                                          }
                                          else
                                          {
                                              _profileImage.image = [UIImage imageNamed:@"profile_page_image.png"];
                                          }
                                      });
                   }
               }];
    
    if (self.userProfile.extendedDetails.location && self.userProfile.extendedDetails.locationVisible) {
        self.locationLabel.text=self.userProfile.extendedDetails.location;
        self.locationIcon.hidden=NO;

        //Reposition the label
        [self.locationLabel sizeToFit];
        CGPoint center = self.locationLabel.center;
        center.x = self.view.center.x;
        self.locationLabel.center = center;

        //Reposition the icon
        CGRect frame = self.locationIcon.frame;
        frame.origin.x = self.locationLabel.frame.origin.x - self.locationIcon.frame.size.width - kLocationLabelLeftOffset;
        self.locationIcon.frame = frame;
    }else{
        self.locationLabel.text=@"";
        self.locationIcon.hidden=YES;
    }

    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(getProfileCounterValueFor:)]) {
        
        self.followersCount.text=[self.ownerDelegate getProfileCounterValueFor:ProfileTabFollowers];
        self.followingsCount.text=[self.ownerDelegate getProfileCounterValueFor:ProfileTabFollowing];
        self.profileViews.text=[self.ownerDelegate getProfileCounterValueFor:ProfileTaUnvisibleProfileViewer];
        
    }
    
    if (!self.isLoggedInUserProfile) {
        self.settingsButton.selected =[[HomeManager sharedInstance] isFollowingUser:_userProfile.userId];
          self.settingsButton.hidden = NO;
    }
}

- (void)setUserProfile:(UserProfile *)currUserProfile isReadOnlyProfile:(BOOL)readOnly{
    
    _userProfile=currUserProfile;
    
    // Other user profile / current user is facebook user
    if (readOnly)
    {
        // Clear icons
        [self.settingsButton setImage:nil forState:UIControlStateNormal];
        [self.settingsButton setImage:nil forState:UIControlStateSelected];
        
        // Clear edge insets, center content
        [self.settingsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.settingsButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        
        
        [self.settingsButton setTitle:NSLocalizedString(@"follow", @"follow") forState:UIControlStateNormal];
        [self.settingsButton setTitle:NSLocalizedString(@"unfollow", @"unfollow") forState:UIControlStateSelected];
        self.findFriendButton.hidden=readOnly;
    }
    
    // Set the right assets to selected | highlighted
    [self.settingsButton setTitle:[self.settingsButton titleForState:UIControlStateSelected] forState:(UIControlStateSelected | UIControlStateHighlighted)];
    [self.settingsButton setImage:[self.settingsButton imageForState:UIControlStateSelected] forState:(UIControlStateSelected | UIControlStateHighlighted)];
}

- (IBAction)editProfileAction:(id)sender {
  
        if([[UserManager sharedInstance] isLoggedIn] == NO)
        {
//            [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_FOLLOW_USER, EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_LOAD_ORIGIN_MENU}];
    
            //open signin dialog in profile base controller
            if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(openSignInDialog) ]) {
                [self.ownerDelegate openSignInDialog];
            }
            return;
        }
    
    //if profile page is currently logged in user, the open profile details
    if (self.isLoggedInUserProfile) {
         self.editProfileButton.selected=YES;
        [self activatePageSelection:ProfileEditProfileViewer];
    

     //other wise follow/unfollow
    }else{
        UIButton * btn=(UIButton*)sender;
         btn.selected = !btn.selected;
        [self updateFollowForViewedUserProfile:btn.selected];
    }
}

- (IBAction)findFriendsAction:(id)sender {
    
    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(findFriendsOpenAction)]) {
        [self.ownerDelegate findFriendsOpenAction];
    }
}

- (IBAction)opendUserProfileReadOnlyAction:(id)sender {
    
    [self activatePageSelection:ProfileTaUnvisibleProfileViewer];

}

#pragma mark - User Actions:
-(void)updateFollowForViewedUserProfile:(BOOL)follow{
    //It works only for profiles that are not logged in user
    
    if(!self.isLoggedInUserProfile){
        
        // Create the follow user info
        FollowUserInfo* currUser = [FollowUserInfo new];
        currUser.userId = self.userProfile.userId;
        currUser.firstName = self.userProfile.firstName;
        currUser.lastName = self.userProfile.lastName;
        currUser.photoUrl = self.userProfile.userPhoto;
        currUser.type = FollowUserTypeNormal;
        currUser.isFollowed = follow;
        
        //the actual server call and correct list updated made from base profile
        if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(followPressed:didFollow:)]) {
            [self.ownerDelegate followPressed:currUser didFollow:follow];
        }
        
    }
}
- (void)activatePageSelection:(ProfileTabs)indexPathTab {
//log flurry
    NSString* event;
    switch (indexPathTab) {
        case ProfileTabDesign:
            event = FLURRY_PROFILE_DESIGNS_MENU_CLICK;
            break;
        case ProfileTabFollowers:
            event = FLURRY_PROFILE_FOLLOWERS_MENU_CLICK;
            break;
        case ProfileTabFollowing:
            event = FLURRY_PROFILE_FOLLOWINGS_MENU_CLICK;
            break;
        case ProfileTabArticles:
            event = FLURRY_PROFILE_ARTICLES_MENU_CLICK;
            break;
        case ProfileTabProfessionals:
            event = FLURRY_PROFILE_PROFESSIONALS_MENU_CLICK;
            break;
        case ProfileTabActivities:
            event = FLURRY_PROFILE_ACTIVITY_MENU_CLICK;
            break;
        default:
            event = nil;
            break;
    }

    // Add "My" so we'll know it's the user's profile
    if ((self.isLoggedInUserProfile) && (event != nil))
    {
        event = [NSString stringWithFormat:@"My %@", event];
    }

//    if(event!= nil) [HSFlurry logAnalyticEvent:event];

    
    self.selectedTab=indexPathTab;
    
    if (self.ownerDelegate && [self.ownerDelegate respondsToSelector:@selector(profileTabSelectionChange:)]) {
        [self.ownerDelegate profileTabSelectionChange:indexPathTab];
    }
}


-(void)openDesignsTab{
    
    [self activatePageSelection:ProfileTabDesign];
}

-(void)openActivityTab{
    
    [self activatePageSelection:ProfileTabActivities];
}

- (IBAction)openFollowingPage:(id)sender
{
    [self.followingsButton setSelected:YES];
    [self.followersButton setSelected:NO];
    
    self.followersCount.highlighted = NO;
    self.followingsCount.highlighted = YES;
    
    [self activatePageSelection:ProfileTabFollowing ];
}

- (IBAction)openFollowersPage:(id)sender
{
    [self.followingsButton setSelected:NO];
    [self.followersButton setSelected:YES];
    
    self.followersCount.highlighted = YES;
    self.followingsCount.highlighted = NO;
    
    [self activatePageSelection:ProfileTabFollowers ];
}

-(void)setSelectedTab:(ProfileTabs)setedTab{
    
    _selectedTab=setedTab;
    
    if (_selectedTab!=ProfileTabFollowers && _selectedTab!=ProfileTabFollowing)
    {
        self.followingsButton.selected = NO;
        self.followersButton.selected = NO;
        
        self.followersCount.highlighted = NO;
        self.followingsCount.highlighted = NO;
    }
    if (_selectedTab!=ProfileEditProfileViewer && self.isLoggedInUserProfile)
    {
        self.editProfileButton.selected=NO;
    }
}
@end
