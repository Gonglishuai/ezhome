//
//  ProfileProfessionalsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileActivitiesViewController.h"
#import "ControllersFactory.h"
#import "UserProfileBaseTableViewController.h"
#import "ProfileBaseViewController.h"
#import "NewBaseProfileViewController.h"
#import "iPadActivityWelcomeTableCell.h"
#import "iPadActivityDesignFeaturedTableCell.h"
#import "iPadActivityDesignLikedTableCell.h"
#import "iPadActivityItemCommentedTableCell.h"
#import "iPadActivityNewArticleTableCell.h"
#import "iPadActivityNewFollowerTableCell.h"
#import "iPhoneActivityWelcomeTableCell.h"
#import "iPhoneActivityDesignFeaturedTableCell.h"
#import "ActivityDesignLikedTableCell_iPhone.h"
#import "iPhoneActivityItemCommentedTableCell.h"
#import "iPhoneActivityNewArticleTableCell.h"
#import "iPhoneActivityNewFollowerTableCell.h"
#import "ActivityStreamDO.h"
#import "ActivityStream.h"
#import "GalleryServerUtils.h"
#import "CommentDO.h"
#import "UIManager.h"
#import <sys/utsname.h>

#define ACTIVITIES_REFRESH_RATE (10) // The number of activities to scroll in order to activate the refresh checkup

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ProfileActivitiesViewController ()
{
    NSTimeInterval  tiKeyboardAnimationDuration;
    CGFloat         fKeyboardHeight;
    BOOL            isCachedActivities;
}

///////////////////// Properties //////////////////////
@property (strong, nonatomic) ActivityStream *activityStream;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic) BOOL loadingNextPage;
@property (nonatomic) BOOL refreshingPage;
@property (nonatomic) BOOL reachedEndOfStream;
@property (strong, nonatomic) ActivityStreamDO *welcomeMessage;
@property (nonatomic, strong) NSMutableArray *cachedActivities;

@end

///////////////////////////////////////////////////////
//                 IMPLEMENTATION                    //
///////////////////////////////////////////////////////

@implementation ProfileActivitiesViewController


- (id)initWithRect:(CGRect)rect delegate:(id<ProfileInstanceDataDelegate, ProfileCountersDelegate, ActivityTableCellDelegate, LikeDesignDelegate, CommentDesignDelegate>)delegate
{
    self = [super initWithRect:rect];
    if (self) {
        self.rootActivityDelegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isCachedActivities = NO;
    tiKeyboardAnimationDuration = 0.1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowWithNotification:) name:UIKeyboardWillShowNotification object:nil];
}

//Forces Table/Collection to reload Data
-(void)refreshContent{
    [self.contentViewer refreshContent];
}

- (void)initContent
{
    [self.contentViewer.view setBackgroundColor:[UIColor clearColor]];
    self.activities = [NSMutableArray array];
    self.loadingNextPage = NO;
    self.refreshingPage = NO;
    self.reachedEndOfStream = NO;
    self.welcomeMessage = [self createWelcomeArticleActivity];
    
    if ([self.rootActivityDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)]) {
        NSString *userId = [self.rootActivityDelegate getUserIDForCurrentProfile];
        if ((userId != nil) && ([userId isEqual:[[[UserManager sharedInstance] currentUser] userID]]))
        {
            [self loadCachedActivities];
        }
    }
    
    [self loadActivities];
    [self.contentViewer initDisplay:self.activities];
}


- (void)initContentViewer
{
    if (self.contentViewer == nil)
    {
        self.contentViewer = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileTableViewVC" inStoryboard:kProfileStoryboard];
        
        self.contentViewer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        if ([self.rootActivityDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)]){
            NSString *userId = [self.rootActivityDelegate getUserIDForCurrentProfile];
            if ((userId != nil) && ([userId isEqual:[[[UserManager sharedInstance] currentUser] userID]]))
            {
                [self.contentViewer setViewDisabled:YES];
            }
        }
        
        [self.contentViewer startLoadingIndicator];
        
        self.contentViewer.dataDelegate = self;
        [self addChildViewController:self.contentViewer];
        [self.view addSubview:self.contentViewer.view];
    }
}

// Lazy instantiation for activityStream member
- (ActivityStream*)activityStream
{
    if (!_activityStream)
    {
        if ([self.rootActivityDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)]){
            _activityStream = [[ActivityStream alloc] initWithUser:[self.rootActivityDelegate getUserIDForCurrentProfile]
                                                         isPrivate:self.isLoggedInUserProfile ];
            
            NSUInteger pageCount = [[[ConfigManager sharedInstance] paginationSizeActivityStream] integerValue];
            [_activityStream setActivityStreamFetchCount:pageCount];
        }
    }
    
    return _activityStream;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlert:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:@"Homestyler messagerie" message:message delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
}

- (ActivityStreamDO*)createWelcomeArticleActivity
{
    ActivityStreamDO *welcomeArticle = [ActivityStreamDO new];
    welcomeArticle.activityType = eActivityWelcome;
    return welcomeArticle;
}

- (void)pushWelcomeMessageToLast
{
    // Only push the welcome message in case the we are viewing our OWN profile
    if (self.isLoggedInUserProfile)
    {
        if ([self.activities containsObject:self.welcomeMessage])
            [self.activities removeObject:self.welcomeMessage];
        
        [self.activities insertObject:self.welcomeMessage atIndex:[self.activities count]];
    }
}

- (void)loadCachedActivities
{
    NSArray *arrAct = [[UIManager sharedInstance] getCachedActivities];
    
    if (arrAct != nil)
    {
        isCachedActivities = YES;
        self.cachedActivities = [arrAct mutableCopy];
        [self.activities removeAllObjects];
        [self.activities addObjectsFromArray:self.cachedActivities];
    }
}

- (void)loadActivities
{
    
    HSCompletionBlock activitiesLoadSuccess = ^(NSArray *activities, NSError *error)
    {
        if (isCachedActivities)
        {
            isCachedActivities = NO;
            self.cachedActivities = nil;
            [self.activities removeAllObjects];
        }
        
        NSUInteger newActivities;
        
        // In case the number of activities is zero, display a default welcome activity
        if ([activities count] == 0)
        {
            [self pushWelcomeMessageToLast];
            newActivities = 1;
        }
        else
        {
            newActivities = self.activityStream.numberOfNewActivites;
            [self.activities addObjectsFromArray:[activities copy]];
        }
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            [self.contentViewer stopLoadingIndicator];
            [self.contentViewer setViewDisabled:NO];
            
            if(self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)] && self.isLoggedInUserProfile)
            {
                NSString * counter=[NSString new];
            
                if (newActivities==[activities count] && newActivities>0 && [activities count]>1) {
                    counter=[NSString stringWithFormat:@"%lu+",(unsigned long)newActivities];
                }else
                {
                    counter=[NSString stringWithFormat:@"%lu",(unsigned long)newActivities];
                }
            
                [self.rootActivityDelegate updateProfileCounterString:counter ForTab:ProfileTabActivities];
            }
        });
    };
    
    HSFailureBlock activitiesLoadFail = ^(NSError *error)
    {
        [self.contentViewer stopLoadingIndicator];
        [self.contentViewer setViewDisabled:NO];
    };
    
    //TODO: Sergei- why
    [self.activityStream getNextItemsWithSuccessAndFailureBlock:activitiesLoadSuccess
                                                   failureBlock:activitiesLoadFail
                                                          queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];

}

- (void)checkCacheExpiration
{
    CacheRefreshCompletionBlock refreshBlock = ^(BOOL needRefresh)
    {
        if (!needRefresh)
        {
            self.refreshingPage = NO;
            [self.activities removeAllObjects];
            [self initContent];
        }
        
    };
    
    CacheRefreshFailedBlock refreshFailure = ^(NSError *error)
    {
        self.refreshingPage = NO;
    };
    
    
    [self.activityStream refreshOnCacheExpiredWithSuccessAndFailureBlock:refreshBlock
                                                            failureBlock:refreshFailure];

}

- (void)reachedRowAtIndex:(NSInteger)rowIndex fromTotalCount:(NSInteger)totalCount
{
    if (isCachedActivities)
    {
        return;
    }
    
    if (rowIndex == totalCount - 1 && !self.loadingNextPage && !self.reachedEndOfStream)
    {
        self.loadingNextPage = YES;
        HSCompletionBlock activitiesLoadSuccess = ^(NSArray *activities, NSError *error)
        {
            self.loadingNextPage = NO;
            
            if ([activities count] == 0 && !self.reachedEndOfStream)
            {
                self.reachedEndOfStream = YES;
                [self pushWelcomeMessageToLast];
                [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            }
            
            // Only refresh the display if we have new data to display
            if ([activities count] > 0)
            {
                [self.activities addObjectsFromArray:[activities copy]];
                [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
                [self refreshContent];
            }
            [self.contentViewer stopLoadingIndicator];
        };
        
        HSFailureBlock activitiesLoadFail = ^(NSError *error)
        {
            self.loadingNextPage = NO;
             [self.contentViewer stopLoadingIndicator];
        };
        
        [self.contentViewer startLoadingIndicator];
        [self.activityStream getNextItemsWithSuccessAndFailureBlock:activitiesLoadSuccess
                                                       failureBlock:activitiesLoadFail
                                                              queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
    }
}

- (NSString *)getCellIdentifierForIndexpath:(NSIndexPath *)path
{
    return NSStringFromClass([self getActivityTableCellClassForActivityType:[self getActivityTypeForIndexpath:path]]);
}

- (UITableViewCell *)getTableViewCellForIndexpath:(NSIndexPath *)path
{
    BaseActivityTableCell *cell = nil;
    NSString * fileName = NSStringFromClass([self getActivityTableCellClassForActivityType:[self getActivityTypeForIndexpath:path]]);
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:fileName owner:self options:nil];
    if ((arr != nil) && (arr.count > 0))
    {
        cell = [arr objectAtIndex:0];
        cell.delegate = (id)self;
    }
    
    return cell;
}

- (NSInteger)heightForRowAtIndexpath:(NSIndexPath *)path
{
    return [[self getActivityTableCellClassForActivityType:[self getActivityTypeForIndexpath:path]] heightForCell];
}

- (NSString *)getMessageForEmptyData:(BOOL)isCurrentUser
{
    if (isCurrentUser)
    {
        return NSLocalizedString(@"myhome_no_activites_copy", "");
    }
    else
    {
        return NSLocalizedString(@"myhome_no_activites_copy_other", "");
    }
}

- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion
{
    if ([self.rootActivityDelegate respondsToSelector:@selector(performLikeForItem:likeState:sender:shouldUsePushDelegate:andCompletionBlock:)]) {
        [self.rootActivityDelegate performLikeForItemId:itemId withItemType:itemType likeState:isLiked sender:sender shouldUsePushDelegate:shouldUsePush andCompletionBlock:completion];
    }
}

#pragma mark - Logic

- (ActivityType)getActivityTypeForIndexpath:(NSIndexPath *)path
{
    ActivityStreamDO *actDO = [self getActivityDOForIndexpath:path];
    
    if (actDO != nil)
    {
        return actDO.activityType;
    }
    
    return eActivityNone;
}

- (ActivityStreamDO *)getActivityDOForIndexpath:(NSIndexPath *)path
{
    NSArray *acts = [self.activities copy];
    
    if (acts.count > path.row)
    {
        ActivityStreamDO *actDO = [acts objectAtIndex:path.row];
        return actDO;
    }
    
    return nil;
}

- (Class)getActivityTableCellClassForActivityType:(ActivityType)type
{
    if (IS_IPAD)
    {
        switch (type)
        {
            case eActivityFeatured:
                return [iPadActivityDesignFeaturedTableCell class];
                break;
            case eActivityLike:
                return [iPadActivityDesignLikedTableCell class];
                break;
            case eActivityComment:
                return [iPadActivityItemCommentedTableCell class];
                break;
            case eActivityArticle:
                return [iPadActivityNewArticleTableCell class];
                break;
            case eActivityFollow:
                return [iPadActivityNewFollowerTableCell class];
                break;
            case eActivityWelcome:
                return [iPadActivityWelcomeTableCell class];
                break;
            case eActivityPublish:
                return [iPadActivityDesignFeaturedTableCell class];
                break;
            case eActivityProfessional:
                return [iPadActivityDesignFeaturedTableCell class];
                break;
            default:
                return [iPadActivityNewArticleTableCell class];
                break;
        }
    }
    else
    {
        switch (type)
        {
            case eActivityFeatured:
                return [iPhoneActivityDesignFeaturedTableCell class];
                break;
            case eActivityLike:
                return [ActivityDesignLikedTableCell_iPhone class];
                break;
            case eActivityComment:
                return [iPhoneActivityItemCommentedTableCell class];
                break;
            case eActivityArticle:
                return [iPhoneActivityNewArticleTableCell class];
                break;
            case eActivityFollow:
                return [iPhoneActivityNewFollowerTableCell class];
                break;
            case eActivityWelcome:
                return [iPhoneActivityWelcomeTableCell class];
                break;
            case eActivityPublish:
                return [iPhoneActivityDesignFeaturedTableCell class];
                break;
            case eActivityProfessional:
                return [iPhoneActivityDesignFeaturedTableCell class];
                break;
            default:
                return [iPhoneActivityNewArticleTableCell class];
                break;
        }
    }
    
    return [BaseActivityNewArticleTableCell class];
}

#pragma mark - Keyboard Control

- (void)keyboardWillShowWithNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    
    value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rEndFrame;
    [value getValue:&rEndFrame];
    
    tiKeyboardAnimationDuration = duration;
    fKeyboardHeight = rEndFrame.size.height;
}

#pragma mark - ActivityTableCellDelegate implementation
-(void)openPhotoFullScreen:(NSString *)designId{
    
}

- (void)openUserProfilePage:(NSString *)profileId
{
    // Disable un-necessary segues in case a user push on his own thumbnail
    if ([self.rootActivityDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)]){
        if ([profileId isEqualToString:[self.rootActivityDelegate getUserIDForCurrentProfile]])
            return;
    }
      
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(openUserProfilePage:)]) {
        [self.rootActivityDelegate openUserProfilePage:profileId];
    }
}

- (void)openFullScreen:(NSString *)designId withType:(ItemType)type{
    if ((self.rootActivityDelegate != nil) && ([self.rootActivityDelegate respondsToSelector:@selector(openFullScreen:withType:)]))
    {
        [self.rootActivityDelegate openFullScreen:designId withType:type];
    }
}

- (void)openDesignFullScreen:(NSString *)designId
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(openDesignFullScreen:)]) {
        [self.rootActivityDelegate openDesignFullScreen:designId];
    }
}

- (void)openArticleFullScreen:(NSString*)articleId
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(openArticleFullScreen:)]) {
        [self.rootActivityDelegate openArticleFullScreen:articleId];
    }
}

- (void)followUser:(FollowUserInfo *)followUser
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(followUser:)])
        [self.rootActivityDelegate followUser:followUser];
}

- (void)unfollowUser:(NSString *)followUserId
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(unfollowUser:)])
        [self.rootActivityDelegate unfollowUser:followUserId];
}

- (void)openCommentScreenForDesign:(NSString *)designId withType:(ItemType)type
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(openCommentScreenForDesign:withType:)])
        [self.rootActivityDelegate openCommentScreenForDesign:designId withType:type];
}

- (UIViewController *)delegateViewController
{
    if (self.rootActivityDelegate && [self.rootActivityDelegate respondsToSelector:@selector(delegateViewController)])
    {
        return [self.rootActivityDelegate delegateViewController];
    }
    
    return nil;
}

- (NSString *)getCommentForActivityId:(NSString *)strId timestamp:(NSTimeInterval)ts
{
    if (strId != nil)
    {
        return [self.activityStream getCommentForActivityWithId:strId timestamp:ts];
    }

    return nil;
}

- (void)commentBox:(UITextView *)commentBox didStartEditingAtCell:(UITableViewCell *)cell
{
    UITableView *table = [(UserProfileBaseTableViewController *) self.contentViewer getTableView];
    
    [UIView animateWithDuration:tiKeyboardAnimationDuration animations:^
     {
         [table scrollToRowAtIndexPath:[table indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:NO];
     }];
}

- (void)commentCelldidFinishWritingCommnet:(NSString *)comment forActivityId:(NSString *)actId
{
    UITableView *table = [(UserProfileBaseTableViewController *) self.contentViewer getTableView];
    ActivityStreamDO *actDO = [self.activityStream getActivityWithId:actId];
    
    //TODO: need to implement a better ux for failing to submit a comment
    if ((actDO != nil) && (actDO.Id != nil))
    {
        //save the comment temporarily so the user would have a good experience
        NSTimeInterval ti = actDO.timeStamp.timeIntervalSince1970;
        [self.activityStream setComment:comment forActivityWithId:actDO.Id timestamp:ti saveToDisk:NO];
    }
    
    [[GalleryServerUtils sharedInstance] addComment:actDO.assetID :comment :@"" :@"" withComplition:^ (CommentDO *backComment, BOOL success)
    {
        if (success == YES)
        {
            if ((actDO != nil) && (actDO.Id != nil))
            {
                NSTimeInterval ti = actDO.timeStamp.timeIntervalSince1970;
                [self.activityStream setComment:comment forActivityWithId:actDO.Id timestamp:ti saveToDisk:YES];
            }

        }
        else
        {
            if ((actDO != nil) && (actDO.Id != nil))
            {
                NSLog(@"Failed to comment from comment activity cell. Activity Id:%@", actDO.Id);
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [table reloadRowsAtIndexPaths:[table indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
                       });
    }];
}

- (void)openHelpEmailPage{
    NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
    NSString * subject;

    if(dict!=NULL)
    {
        subject= NSLocalizedString(@"feedback_email_subject",@"Share with Homestyler Team");
        NSString * body;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
        
        
        struct utsname systemInfo;
        uname(&systemInfo);
        
        NSString * dd = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        NSString *osversion=[UIDevice currentDevice].systemVersion;
        body=[NSString stringWithFormat:@"\n\n\n----------------------------------------\n%@ version: %@-%@\n Device: %@\nVersion: %@",[ConfigManager getAppName],version,build,dd,osversion];
        [[UIMenuManager sharedInstance] createEmailWithTitle:subject andBody:body forPresentingTarget:self
                                              withRecipients:[NSArray arrayWithObject:[[dict objectForKey:@"feedback"] objectForKey:@"toaddress"]] ];
    }
}

- (BOOL)isCurrentCellOfLoggedInUser
{
    return self.isLoggedInUserProfile;
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
