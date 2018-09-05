//
//  BaseUserRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/28/13.
//
//

#import "BaseRO.h"
#import "UserProfile.h"
#import "FollowUserInfo.h"

typedef enum UserLikesItemTypes{
    
    kLike3DItems =1,
    kLike2DItems =2,
    kLikeArticleItems =3,
    kLikeAllItems =4
    
    
}UserLikesItemType;
@interface BaseUserRO : BaseRO


- (void)getUserFollowingsById:(NSString*)userId
                       offset:(NSUInteger)offset
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue;

- (void)getUserFollowersById:(NSString*)userId
                      offset:(NSUInteger)offset
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

//Virtual method overrided by subclasses
- (void)getUserProfileById:(NSString*)userId
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;



- (void)getUserLikes:(NSString*)userId withType:(UserLikesItemType)itemType
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;

- (void)getUserCombosWithcompletionBlock:(ROCompletionBlock)completion
        failureBlock:(ROFailureBlock)failure
               queue:(dispatch_queue_t)queue;
@end
