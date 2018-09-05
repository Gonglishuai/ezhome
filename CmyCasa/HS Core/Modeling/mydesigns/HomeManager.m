//
//  HomeManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/15/13.
//
//

#import "HomeManager.h"
#import "UserRO.h"
#import "OtherUserRO.h"
#import "NSString+JSONHelpers.h"
#import "UserLikesDO.h"
#import "DesignRO.h"
#import "FriendsInviterManager.h"
#import "NotificationNames.h"

//#import "HSFlurry.h"

@interface HomeManager ()
{
    dispatch_queue_t _workingQueue;
}

@property(nonatomic, strong) UserProfile* myProfile;
@property(nonatomic, strong) FriendsInviterManager * fim;
@property(nonatomic) BOOL needArticlesReloadFromServer;

-(void)getMyArticlesInternalWithCompletion:(UIRefreshCompletionBlock)complitionBlock;

@end

@implementation HomeManager

@synthesize myArticles;
@synthesize needArticlesReloadFromServer;

static HomeManager *sharedInstance = nil;

+ (HomeManager *)sharedInstance {

    static dispatch_once_t pred;        // Lock

    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[HomeManager alloc] init];
    });
    
    return sharedInstance;
}

-(UserProfile*)getCurrentStoredProfileForLoggedInUser{
   
    return sharedInstance.myProfile;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        self.myArticles = [NSMutableArray arrayWithCapacity:0];
        self.needArticlesReloadFromServer = YES;
        self.userFollowersList = [NSMutableArray arrayWithCapacity:0];
        self.userFollowingList = [NSMutableArray arrayWithCapacity:0];
        self.isInitializedFollowersList=NO;
        self.isInitializedFollowingList=NO;
        
        _fim = [[FriendsInviterManager alloc] init];
        
        _workingQueue = dispatch_queue_create("com.autodesk.workingQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    return self;
}

-(void)logout{
    self.needArticlesReloadFromServer=YES;
    
    self.isInitializedMyArticlesList=NO;
    self.isInitializedFollowersList=NO;
    self.isInitializedFollowingList=NO;
    self.isInitializedMyDesignsList=NO;
    
    [self.myArticles removeAllObjects];
    [self.userFollowingList removeAllObjects];
    [self.userFollowersList removeAllObjects];
    self.isInitializedFollowersList = NO;
    self.isInitializedFollowingList = NO;
    self.myProfile = nil;
}

#pragma mark - Profile
- (void)executeProfileActionInternal:(ROCompletionBlock)completionBlock
        failureBlock:(ROFailureBlock)failure{
    
    
    //for my user will use session id internally
    [[UserRO new] getUserProfileById:nil completionBlock:^(id serverResponse) {
        UserProfile* profile = serverResponse;
        
        if (profile && profile.errorCode < 0)
        {
            //Update local storage
            self.myProfile = profile;
            
            [[UserManager sharedInstance] updateUserDOWithUserProfile:self.myProfile];
           
            // Check that we got an array
            if (self.myProfile.assets)
            {
                [[DesignsManager sharedInstance] fillWithDesigns:self.myProfile.assets];
            }
        }
        
        //Update UI
        completionBlock(serverResponse);
    } failureBlock:failure queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)addLocalySavedDesignsFrom:(NSMutableArray *)array onTopOf:(NSMutableArray *)of {

    for (int k = 0; k <array.count ; k++) {
        [of insertObject:array[k] atIndex:0];
    }

}

- (void)getMyProfile:(ROCompletionBlock)completionBlock
        failureBlock:(ROFailureBlock)failure
{    
    if ([ConfigManager isAnyNetworkAvailable:YES] == NO) {
        if (failure != nil)
        {
            failure(nil);
        }

        return ;
    }
    
    [self executeProfileActionInternal:completionBlock failureBlock:failure];
}

-(void)fillWithArticles:(NSMutableArray*)articles{
    
    self.needArticlesReloadFromServer = NO;
    [self.myArticles removeAllObjects];
    [self.myArticles addObjectsFromArray:[articles copy]];
}

#pragma mark - Articles
-(GalleryItemDO*)findArticleByID:(NSString*)articleID{
    for (int i=0; i<[self.myArticles count];i++ ) {
        if ([[[self.myArticles objectAtIndex:i] _id] isEqualToString:articleID]) {
            
            return [self.myArticles objectAtIndex:i];
        }
    }
    
    return nil;
}

-(void)getMyHomeArticlesWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                          failureBlock:(ROFailureBlock)failureBlock
{
    
    
    
    //1. Check if inital data exists, not exists load it
    
    if (self.isInitializedMyArticlesList==NO) {
        //sync call
        
        [self getMyArticlesInternalWithCompletion:complitionBlock];
   
    }else{
        //async call
        
        
        NSString * userId=[[[UserManager sharedInstance] currentUser]userID];
        
        //2. Check with Cache Inspector if we have timestamp
        [self checkCacheValidationForUser:userId forAction:kCacheMyArticles withCompleteBlock:^(BOOL needRefresh) {
   
            if (needRefresh)
                [self getMyArticlesInternalWithCompletion:complitionBlock];
        } failureBlock:failureBlock  queue:_workingQueue];
    }
}

-(void)getMyArticlesInternalWithCompletion:(UIRefreshCompletionBlock)complitionBlock{
    NSString * userid=[[[UserManager sharedInstance] currentUser] userID];
    
    [[UserManager sharedInstance] getUserLikedArticles:userid completionBlock:^(id serverResponse, id error) {
        
        
        if (!error) {
            UserLikesDO * response=(UserLikesDO*)serverResponse;
            
            if (response && [response isKindOfClass:[UserLikesDO class]]) {
                
                [self.myArticles removeAllObjects];
                
                NSMutableDictionary*  likeDict = [GalleryStreamManager sharedInstance].likeDesignDictionary ;
                
                for(int i=0;i<[response.designs count];i++){
                    GalleryItemDO * des=[response.designs objectAtIndex:i];
                                        
                    LikeDesignDO*  likeDO = [likeDict  objectForKey:des._id];
                    
                    likeDO.isUserLiked = YES;
                    
                    [self.myArticles addObject:des];
                }
                
                self.needArticlesReloadFromServer=NO;
                self.isInitializedMyArticlesList=YES;
            }
        }
        
        if (complitionBlock) {
            complitionBlock();
        }
    } queue:_workingQueue];
}

-(void)getArticlesForUser:(NSString*)userId witchComplition:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [[UserManager sharedInstance] getUserLikedArticles:userId completionBlock:^(id serverResponse, id error) {
        
        if (error) {
         if(completion)completion(nil,error);
        
        }else{
            UserLikesDO* likes=(UserLikesDO*)serverResponse;
            if (likes && [likes isKindOfClass:[UserLikesDO class]] && likes.errorCode==-1) {
                if(completion)completion(serverResponse,nil);
            }else{
               if(completion)completion(nil,error);
            }
        }
    } queue:queue];
}

-(void)addLikedArticle:(GalleryItemDO * )article{
    
    [article createCustomArticle];
    if ([self findArticleByID:article._id]) {
        return;
        //already exists
    }else{
        
        [self.myArticles addObject:article];
    }
}

-(void)removeLikedArticle:(NSString * )itemid{
    
    GalleryItemDO * art=[self findArticleByID:itemid];
    
    if (art) {
        [self.myArticles removeObject:art];
    }
}

#pragma mark- Followers/Following
-(void)getFollowingForUser:(NSString*)userId
                    offset:(NSUInteger)offset
            withCompletion:(ROCompletionBlock)complition
              failureBlock:(ROFailureBlock)failureBlock
            queue:(dispatch_queue_t)queue
{
    if ( userId==nil) {
        failureBlock(nil);
        return;
    }
        // Get following 
    [[OtherUserRO new] getUserFollowingsById:userId
                                      offset:offset
                             completionBlock:complition
                                failureBlock:failureBlock queue:queue];
}

-(void)getFollowersForUser:(NSString*)userId
                    offset:(NSUInteger)offset
            withCompletion:(ROCompletionBlock)complition
              failureBlock:(ROFailureBlock)failureBlock
                queue:(dispatch_queue_t)queue
{
    if ( userId==nil) {
        failureBlock(nil);
        return;
    }
     // Get following / followers
    [[OtherUserRO new]
     getUserFollowersById:userId
     offset:offset
     completionBlock:complition
     failureBlock:failureBlock
     queue:queue];
}

-(void)getMyFollowingWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                       failureBlock:(ROFailureBlock)failureBlock
queue:(dispatch_queue_t)queue
{
    NSString* userId = [[[UserManager sharedInstance] currentUser]userID];
    
    if (userId==nil) {
        failureBlock(nil);
        return;
    }
    
    //Check with Cache Inspector if we need to refresh or if the following list is initialized
    [self checkCacheValidationForUser:userId forAction:kCacheFollowingOtherUsers withCompleteBlock:^(BOOL needRefresh) {     
        
        if (needRefresh || self.isInitializedFollowingList==NO) {
            
            [[UserRO new]
             getUserFollowingsById:userId
             offset:0
             completionBlock:^(id serverResponse) {
                 
                 //Update local storage
                 FollowResponse* response = serverResponse;
                 NSMutableArray * arr = (NSMutableArray*)response.followList;
                 [sharedInstance fillWithFollowings:arr];
                 //Update UI
                 if(complitionBlock)
                     complitionBlock();
                 
             }
             failureBlock:failureBlock queue:queue];
        }else {
            if(complitionBlock) {
                complitionBlock();
            }
        }
        
    } failureBlock:failureBlock  queue:_workingQueue];
}

-(void)getMyFollowersWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                       failureBlock:(ROFailureBlock)failureBlock
                                queue:(dispatch_queue_t)queue
{
    NSString* userId = [[[UserManager sharedInstance] currentUser] userID];
    
    if ( userId==nil) {
        failureBlock(nil);
        return;
    }
    
    //Check with Cache Inspector if we need to refresh or if the followers list is initialized
    [self checkCacheValidationForUser:userId forAction:kCacheFollowersByUsers withCompleteBlock:^(BOOL needRefresh) {
        
        if (needRefresh || self.isInitializedFollowersList==NO) {
            [[UserRO new]
             getUserFollowersById:userId
             offset:0
             completionBlock:^(id serverResponse) {
                 
                 //Update local storage
                 FollowResponse* response = serverResponse;
                 NSMutableArray * arr = (NSMutableArray*)response.followList;
                 [sharedInstance fillWithFollowers:arr];
                 //Update UI
                 complitionBlock();
                 
             }
             failureBlock:failureBlock queue:queue];
        }
        else {
            complitionBlock();
        }
        
    } failureBlock:failureBlock  queue:_workingQueue];
}

-(void)fillWithFollowers:(NSMutableArray*)followers{
    self.isInitializedFollowersList=YES;
    [self.userFollowersList removeAllObjects];
    [self.userFollowersList addObjectsFromArray:[followers copy]];
}

- (NSInteger)findFollowingUserById:(NSString*)userId {
    for (NSInteger i = 0; i < [self.userFollowingList count]; i++) {
        if ([[[self.userFollowingList objectAtIndex:i] userId] isEqualToString:userId])
            return i;
    }
    return -1;
}

-(BOOL)isFollowingUser:(NSString*)userId {
    return [self findFollowingUserById:userId] >= 0;
}

-(void)addFollowingUserFromFriend:(UserBaseFriendDO*)newfollow{
    
    FollowUserInfo * finfo=[[FollowUserInfo alloc] init];
    
    finfo.email=newfollow.email;
    finfo.firstName=newfollow.firstName;
    finfo.lastName=newfollow.lastName;
    finfo.type=FollowUserTypeNormal;
    finfo.userId=newfollow._id;
    finfo.photoUrl=newfollow.picture;
    finfo.type = FollowUserTypeNormal;
    finfo.isFollowed=YES;
    [sharedInstance addFollowingUser:finfo];
}

-(void)addFollowingUser:(FollowUserInfo*)newfollow{

    if ([self isFollowingUser:newfollow.userId])
        return;

    [self.userFollowingList addObject:newfollow];
}

-(void)removeFollowingUser:(FollowUserInfo*)oldfollow{
    NSInteger pos = [self findFollowingUserById:oldfollow.userId];
    if (pos >= 0) {
        [self.userFollowingList removeObjectAtIndex:pos];
    }
}

-(void)fillWithFollowings:(NSMutableArray*)followings{
    self.isInitializedFollowingList=YES;
    [self.userFollowingList removeAllObjects];
    
    
    for (FollowUserInfo* currUser in followings) {
            currUser.isFollowed = YES;
    }
    
    [self.userFollowingList addObjectsFromArray:[followings copy]];
}

-(void)initializeMyTimestamps:(NSString*)ts{
    NSMutableDictionary *tmpDict = [self.cachedTimestamps mutableCopy];
    
    [tmpDict setObject:ts forKey:kCacheMyDesigns];
    [tmpDict setObject:ts forKey:kCacheFollowersByUsers];
    [tmpDict setObject:ts forKey:kCacheFollowingOtherUsers];
    [tmpDict setObject:ts forKey:kCacheMyArticles];
    
    [self setCachedTimestamps:tmpDict];
}

#pragma mark - Follow
-(void)followUser:(NSString*)userId
           follow:(BOOL)follow
   withCompletion:(ROCompletionBlock)complition
     failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue {

#ifdef USE_FLURRY
    if (follow) {
//        [HSFlurry logAnalyticEvent:EVENT_NAME_FOLLOW_CLICK];
    }
#endif
    
    [[UserRO new] followUser:userId
                      follow:follow
             completionBlock:^(id serverResponse) {
                 BaseResponse * response=(BaseResponse*)serverResponse;
                 //if (response && response.errorCode==-1) {
                     //[_fim updateFollowingStatesAfterFollowChange:userId isFollow:follow];
                 //}
                 if (complition) {
                     complition(response);
                 }
                 if (response && response.errorCode==-1) {
                     [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationUserFollowingStatusChanged object:nil userInfo:@{ kNotificationKeyUserId:userId, @"isFollowed":@(follow) }]];
                 }
             }
                failureBlock:nil queue:_workingQueue];
}

@end
