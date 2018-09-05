//
//  ProfileFollowingsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import "ProfileFollowingsViewController.h"
#import "FollowUserItemCollectionView.h"
#import "ControllersFactory.h"
#import "HSSharingConstants.h"

@interface ProfileFollowingsViewController ()
@property (strong, nonatomic) NSMutableArray* followings;
@end

@implementation ProfileFollowingsViewController

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
	// Do any additional setup after loading the view.
    
    self.followingRemove = [NSMutableArray array];
}

//Forces Table/Collection to reload Data
-(void)refreshContent{
    [self.contentViewer refreshContent];
    [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
    if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)] && self.isDataLoaded){
        
        [self.rootFollowDelegate updateProfileCounter:(int)self.followings.count ForTab:ProfileTabFollowing];
    }
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

-(void)initContent {
    
    if (self.isLoggedInUserProfile) {
        self.followings = [[HomeManager sharedInstance] userFollowingList];
        
    }else{
        self.followings =[NSMutableArray array];
        
    }
    [self loadFollowing];
    [self.contentViewer initDisplay:self.followings];
    
}

- (void)addOrRemoveFollowUser:(FollowUserInfo *)info andFollowStatus:(BOOL)follow{
    
    if (follow){
        if([self.followingRemove indexOfObject:info]!=NSNotFound)
        {
            [self.followingRemove removeObject:info];
        }else{
            [self.followings addObject:info];
        }
        
    }else{
        if ([self.followingRemove indexOfObject:info]==NSNotFound) {
            [self.followingRemove addObject:info];
        }
    }
    
    if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
        
        [self.rootFollowDelegate updateProfileCounter:(int)self.followings.count - (int)self.followingRemove.count ForTab:ProfileTabFollowing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self updateFollowings];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateFollowStatus];
    [self updateFollowings];
    [self refreshContent];
}

#pragma mark - FollowUserItemDelegate

- (void)updateFollowStatus
{
    UIRefreshCompletionBlock setFollowStatus = ^() {
        
        NSArray* connectedUserFollowing = [[HomeManager sharedInstance] userFollowingList];
        
        for (FollowUserInfo* currFollowing in self.followings)
        {
            NSUInteger followingIndex = [connectedUserFollowing indexOfObject:currFollowing];
            currFollowing.isFollowed = followingIndex != NSNotFound;
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
    };
    
    // If the list should be loaded
    if (![[HomeManager sharedInstance] userFollowingList])
    {
        [[HomeManager sharedInstance]
         getMyFollowingWithCompletion:setFollowStatus
         failureBlock:^(NSError *error) {
             
             setFollowStatus();
         }queue:dispatch_get_main_queue()];
    }
    else
    {
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
- (void)updateFollowings
{
    // Update following if needed
    if (self.followingRemove.count > 0)
    {
        for (int i=0; i<self.followingRemove.count; i++) {
            [self.followings removeObject:self.followingRemove[i]];
        }
        [self.followingRemove removeAllObjects];
    }
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



#pragma mark - Load Actual Data

-(void)loadFollowing{
    
    if (self.isLoggedInUserProfile) {
        // Get following
        [[HomeManager sharedInstance]
         getMyFollowingWithCompletion:^{
             self.followings=[[HomeManager sharedInstance] userFollowingList];
             self.isDataLoaded=YES;
             [self updateFollowStatus];
             [self updateFollowings];
             [self.contentViewer stopLoadingIndicator];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
             if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                 
                 [self.rootFollowDelegate updateProfileCounter:(int)self.followings.count ForTab:ProfileTabFollowing];
             }
         }
         failureBlock:^(NSError *error) {
             [self.contentViewer stopLoadingIndicator];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
         } queue:dispatch_get_main_queue()];
        
    }else{
        // Load the lists
        
        NSString * userId;
        
        if (self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(getUserIDForCurrentProfile)])
        {
            userId= [self.rootFollowDelegate getUserIDForCurrentProfile];
        }
        
        if (!userId)
        {
            [self.contentViewer stopLoadingIndicator];
            return;
        }
        [[HomeManager sharedInstance]
         getFollowingForUser:userId
         offset:0
         withCompletion:^(id serverResponse) {
             
             
             [self.followings removeAllObjects];
             [self.followings addObjectsFromArray:[serverResponse copy]];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
             [self updateFollowStatus];
             [self updateFollowings];
             self.isDataLoaded=YES;
             
             [self.contentViewer stopLoadingIndicator];
             
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
             
             if(self.rootFollowDelegate && [self.rootFollowDelegate respondsToSelector:@selector(updateProfileCounter:ForTab:)]){
                 
                 [self.rootFollowDelegate updateProfileCounter:(int)self.followings.count ForTab:ProfileTabFollowing];
             }
             
         }
         failureBlock:^(NSError *error) {
             [self.contentViewer stopLoadingIndicator];
             [self.contentViewer updateDisplay:self.isLoggedInUserProfile];
         }queue:dispatch_get_main_queue()];
        
    }
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{
    if (isCurrentUser)
        return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_following_copy", ""), [ConfigManager getAppName]];
    else
        return [NSString stringWithFormat:NSLocalizedString(@"myhome_no_following_copy_other", ""), [ConfigManager getAppName]];
}

-(void)rowSelectedAtIndex:(NSIndexPath*)indexPath{
    
}


@end
