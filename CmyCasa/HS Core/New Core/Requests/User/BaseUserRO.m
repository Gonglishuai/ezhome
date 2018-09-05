//
//  BaseUserRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/28/13.
//
//

#import "BaseUserRO.h"
#import "UserLikesDO.h"
#import "UserCombosResponse.h"
#import "UserComboDO.h"
@implementation BaseUserRO

+ (void)initialize
{
   
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetFollowings]
                                    withMapping:[FollowResponse jsonMapping]];
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetFollowers]
                                    withMapping:[FollowResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] USER_LIKES_URL]
                                    withMapping:[UserLikesDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getUserCombosURL]
                                    withMapping:[UserCombosResponse jsonMapping]];
}

- (void)getUserFollowingsById:(NSString*)userId
                       offset:(NSUInteger)offset
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue {
    self.requestQueue = queue;

    NSMutableDictionary * params = [@{@"createId":userId, @"offset":@(offset), @"limit":@(100)} mutableCopy];
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [params setObject:[[UserManager sharedInstance] getSessionId] forKey:@"s"];
    }

    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetFollowings]
                       params:params
                  withHeaders:NO
              completionBlock:^(id serverResponse) {
                  if (completion) {
                      completion(serverResponse);
                  }
              }
                 failureBlock:failure];
}

- (void)getUserFollowersById:(NSString*)userId
                      offset:(NSUInteger)offset
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;

    NSMutableDictionary * params = [@{@"followId":userId, @"offset":@(offset), @"limit":@(100)} mutableCopy];
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [params setObject:[[UserManager sharedInstance] getSessionId] forKey:@"s"];
    }

    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetFollowers]
                       params:params
                  withHeaders:NO
              completionBlock:^(id serverResponse) {
                  if (completion) {
                      completion(serverResponse);
                  }
              }
                 failureBlock:failure];
}

- (void)getUserLikes:(NSString*)userId
            withType:(UserLikesItemType)itemType
     completionBlock:(ROCompletionBlock)completion
        failureBlock:(ROFailureBlock)failure
               queue:(dispatch_queue_t)queue{

    self.requestQueue = queue;
    
    if (!userId) {
        return;
    }

    NSMutableDictionary * params = [@{@"id":userId, @"tp":[NSNumber numberWithInt:itemType]} mutableCopy];

    [self getObjectsForAction:[[ConfigManager sharedInstance] USER_LIKES_URL]
                       params:params
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
}


- (void)getUserCombosWithcompletionBlock:(ROCompletionBlock)completion
                            failureBlock:(ROFailureBlock)failure
                                   queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] getUserCombosURL]
                       params:nil
                  withHeaders:NO
              completionBlock:completion failureBlock:failure];
}

- (void)getUserProfileById:(NSString*)userId
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    //implement in son's
}

@end
