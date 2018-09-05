//
//  FindFriendsRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "BaseRO.h"

@interface FindFriendsRO : BaseRO


- (void)findUserByName:(NSDictionary*)searchDictionary
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue;


- (void)findUserByEmail:(NSDictionary*)searchDictionary
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue;


-(void)findFacebookFriends:(NSString*)accessToken
withCompletionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue;



- (void)invitationSentViaEmail:(NSString*)hashedEmail
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue;


- (void)invitationSentViaFacebook:(NSString*)facebookId
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue;
@end
