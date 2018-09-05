//
//  HomeManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/15/13.
//
//

#import <Foundation/Foundation.h>
#import "MyDesignDO.h"
#import "DesignBaseClass.h"
#import "BaseManager.h"
#import "GalleryItemDO.h"
#import "FollowUserInfo.h"
#import "UserProfile.h"
#import "UserBaseFriendDO.h"

static NSString* const kCacheMyProfile = @"my_profile";

static NSString* const kCacheFollowingOtherUsers = @"my_following_users";

static NSString* const kCacheFollowersByUsers = @"my_follower_users";

static NSString* const kCacheMyDesigns = @"my_designs";

static NSString* const kCacheMyArticles = @"my_articles";

static NSString* const kCacheMyActivities = @"my_activities";


@interface HomeManager : BaseManager <NSCoding>




+ (HomeManager *)sharedInstance;



#pragma mark- Designs

-(void)logout;



-(GalleryItemDO*)findArticleByID:(NSString*)articleID;
-(void)fillWithArticles:(NSMutableArray*)articles;
-(void)fillWithFollowers:(NSMutableArray*)followers;
-(void)fillWithFollowings:(NSMutableArray*)followings;

#pragma mark - Profile

-(UserProfile*)getCurrentStoredProfileForLoggedInUser;
- (void)addLocalySavedDesignsFrom:(NSMutableArray *)array onTopOf:(NSMutableArray *)of;
- (void)getMyProfile:(ROCompletionBlock)completionBlock
        failureBlock:(ROFailureBlock)failure;

#pragma mark- Articles
-(void)getMyHomeArticlesWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                          failureBlock:(ROFailureBlock)failureBlock;
-(void)addLikedArticle:(GalleryItemDO * )article;
-(void)removeLikedArticle:(NSString * )itemid;

-(void)getArticlesForUser:(NSString*)userId witchComplition:(HSCompletionBlock)completion
                    queue:(dispatch_queue_t)queue;


#pragma mark - Following/Followers
-(void)removeFollowingUser:(FollowUserInfo*)oldfollow;
-(void)addFollowingUser:(FollowUserInfo*)newfollow;
-(void)addFollowingUserFromFriend:(UserBaseFriendDO*)newfollow;

-(BOOL)isFollowingUser:(NSString*)userId;

-(void)getFollowingForUser:(NSString*)userId
                    offset:(NSUInteger)offset
            withCompletion:(ROCompletionBlock)complition
              failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue;

-(void)getFollowersForUser:(NSString*)userId
                    offset:(NSUInteger)offset
            withCompletion:(ROCompletionBlock)complition
              failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue;


-(void)followUser:(NSString*)userId
           follow:(BOOL)follow
            withCompletion:(ROCompletionBlock)complition
              failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue;


-(void)getMyFollowingWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                       failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue;
-(void)getMyFollowersWithCompletion:(UIRefreshCompletionBlock)complitionBlock
                       failureBlock:(ROFailureBlock)failureBlock queue:(dispatch_queue_t)queue;

@property(nonatomic, strong) NSMutableArray* myArticles;
@property(nonatomic, strong) NSMutableArray * userFollowersList;
@property(nonatomic, strong) NSMutableArray * userFollowingList;
@property(nonatomic) BOOL  isInitializedFollowersList;
@property(nonatomic) BOOL  isInitializedFollowingList;
@property(nonatomic) BOOL  isInitializedMyDesignsList;
@property(nonatomic) BOOL  isInitializedMyArticlesList;

@end
