//
//  OtherUserRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/28/13.
//
//

#import "OtherUserRO.h"
#import "UserManager.h"

@implementation OtherUserRO
+ (void)initialize
{
  
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionUserProfile]
                                    withMapping:[UserProfile jsonMapping]];
   
}





#pragma mark-
#pragma mark- Base class overrides
- (void)getUserProfileById:(NSString*)userId
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue
{
    if (userId==nil) {
        
        if (failure != nil)
        {
            failure(nil);
        }
        
        return;
    }
    self.requestQueue=queue;
    NSMutableDictionary * params = [@{@"id": userId} mutableCopy];
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [params setObject:[[UserManager sharedInstance] getSessionId] forKey:@"sk"];
    }
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionUserProfile]
                       params:params
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
}

@end
