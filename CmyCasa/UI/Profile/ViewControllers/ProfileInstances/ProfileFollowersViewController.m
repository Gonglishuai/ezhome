//
// Created by Berenson Sergei on 12/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "ProfileFollowersViewController.h"
#import "FollowUserItemCollectionView.h"
#import "HSSharingConstants.h"
#import "ControllersFactory.h"

@interface ProfileFollowersViewController ()

@property (strong, nonatomic) NSMutableArray* followers;
@end


@implementation ProfileFollowersViewController
- (void)addOrRemoveFollowUser:(FollowUserInfo *)info andFollowStatus:(BOOL)follow{

    if (follow){
        [self.followers addObject:info];
    }else{
        [self.followers removeObject:info];
    }

    if (self.isDataLoaded) {
        if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
            
            [self.rootFollowDelegate updateProfileCounter:(int)self.followers.count ForTab:ProfileTabFollowers];
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
    {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            // Custom initialization
        }
        return self;
}

- (void)viewDidLoad
{
        [super viewDidLoad];
        // Do any additional setup after loading the view
}

//Forces Table/Collection to reload Data
-(void)refreshContent{
    [self.contentViewer refreshContent];

    if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]&& self.isDataLoaded){
        
        [self.rootFollowDelegate updateProfileCounter:(int)self.followers.count ForTab:ProfileTabFollowers];
    }
}

-(void)initContent {
    if (self.isLoggedInUserProfile) {
        self.followers = [[HomeManager sharedInstance] userFollowersList];
    }else{
        self.followers =[NSMutableArray array];
    }
    
    // 1. call for load Followers
    [self loadFollowers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initContentViewer{

    if(self.contentViewer== nil)
    {
       self.contentViewer=[ControllersFactory instantiateViewControllerWithIdentifier:@"UserProfileCollectionVC" inStoryboard:kProfileStoryboard];

        if (IS_IPAD) {
            self.contentViewer.view.frame=CGRectMake(18, 18, self.view.frame.size.width-18, self.view.frame.size.height-36);
            
        }else
            self.contentViewer.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        [self.contentViewer startLoadingIndicator];

        self.contentViewer.dataDelegate=self;
        [self addChildViewController:self.contentViewer];
        [self.view addSubview:self.contentViewer.view];
    }
}

-(void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];

        [self updateFollowStatus];
}

#pragma mark - ProfilePageCollectionViewDelegate
-(Class)getCollectionCellClass{
    if (IS_IPAD) {
       return  [FollowUserItemCollectionView class];
    }else{
        return  [FollowUserSingle class];
    }
}

-(CollectionViewRowsSize)getCollectionGridSize{
     CollectionViewRowsSize size;
    if(IS_IPAD){
        size.collumnsCount = 5;
        size.minRowsCount = 3;
        
    }else{
        size.collumnsCount = 2;
        size.minRowsCount = 1;
    }
    
    return  size;
}

-(UIEdgeInsets) getCellEdgeInsets{
    if (IS_IPAD) {
        return UIEdgeInsetsMake(0, 0, 0, 20);
    }else{
        return UIEdgeInsetsMake(20, 20, 0, 20);
    }
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        return CGSizeMake(230, 230);
    }else{
        return CGSizeMake(133, 185);
    }
}

-(CGFloat)minimumLineSpacingForSection
{
    return 20.0;
}

#pragma mark - FollowUserItemDelegate
- (void)updateFollowStatus
{
    UIRefreshCompletionBlock setFollowStatus = ^() {

        NSArray* connectedUserFollowing = [[HomeManager sharedInstance] userFollowingList];



        for (FollowUserInfo* currFollower in self.followers)
        {
            NSUInteger followerIndex = [connectedUserFollowing indexOfObject:currFollower];
            currFollower.isFollowed = followerIndex != NSNotFound;
        }

        // Check if the shown user if followed by logged in user
        if (!self.isLoggedInUserProfile)
        {
            FollowUserInfo* shownUser = [FollowUserInfo new];
            NSString * userId;

            if (self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)])
            {
                userId= [self.rootFollowDelegate getUserIDForCurrentProfile];
                shownUser.userId = userId;
            }
        }
        [self.contentViewer refreshContent];
        
    };

    // If the list should be loaded
    if (![[HomeManager sharedInstance] userFollowingList])
    {
        [[HomeManager sharedInstance]
                getMyFollowingWithCompletion:setFollowStatus
                                failureBlock:^(NSError *error) {
                                }queue:dispatch_get_main_queue()];
    }else{
        setFollowStatus();
    }
}

- (void)userPressed:(FollowUserInfo *)info
{
    if (self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(userPressed:)]) {
        [self.rootFollowDelegate userPressed:info];
    }
}

- (void)followPressed:(FollowUserInfo*)info
            didFollow:(BOOL)follow{
    if (self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(followPressed:didFollow:)]) {
        [self.rootFollowDelegate followPressed:info didFollow:follow];
        
    }
}

#pragma mark - Load Actual Data
-(void)loadFollowers{
    
    if (self.isLoggedInUserProfile) {
        // Get followers
        [[HomeManager sharedInstance] getMyFollowersWithCompletion:^{
            
            self.followers = [[HomeManager sharedInstance] userFollowersList];
            self.isDataLoaded = YES;
            [self.contentViewer initDisplay:self.followers];
            
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];

            [self.contentViewer stopLoadingIndicator];
            [self updateFollowStatus];
            
             if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                 [self.rootFollowDelegate updateProfileCounter:(int)self.followers.count ForTab:ProfileTabFollowers];
             }
         }
         failureBlock:^(NSError *error) {
             [self.contentViewer stopLoadingIndicator];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
         } queue:dispatch_get_main_queue()];
    }else{
        
        NSString * userId;
        
        if (self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)])
        {
            userId = [self.rootFollowDelegate getUserIDForCurrentProfile];
        }
        
        if (!userId)
        {
            [self.contentViewer stopLoadingIndicator];
            return;
        }
        
        //API CALL getFollowersForUser
        [[HomeManager sharedInstance] getFollowersForUser:userId offset:0 withCompletion:^(id serverResponse) {
        
            [self.followers removeAllObjects];
            [self.followers addObjectsFromArray:[((FollowResponse*)serverResponse).followList copy]];
            
            [self.contentViewer initDisplay:self.followers];
            
            [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
            
            self.isDataLoaded=YES;
            [self updateFollowStatus];
             
            [self.contentViewer stopLoadingIndicator];
                          
            if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                 
                 [self.rootFollowDelegate updateProfileCounter:(int)self.followers.count ForTab:ProfileTabFollowers];
            }
         }
         failureBlock:^(NSError *error) {
             [self.contentViewer stopLoadingIndicator];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
         } queue:dispatch_get_main_queue()];
    }
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{
    if (isCurrentUser)
       return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_followers_copy", "")];
    else
        return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_followers_copy_other", "")];
}

#pragma mark - ProfessionalCellDelegate  For Iphone Version
-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath{

}

@end
