//
//  FindFriendsRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsRO.h"
#import "FindFriendsResponse.h"
#import "NSString+EmailValidation.h"
#import "SocialFindFriendsResponse.h"
#import "AddrBookFriendsResponse.h"
#import <RestKit.h>
@interface FindFriendsRO ()

@end

@implementation FindFriendsRO


+(void)initialize{
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]searchHSUsersURL]
                                    withMapping:[AddrBookFriendsResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]searchSocialUsersURL]
                                    withMapping:[SocialFindFriendsResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]inviteFriendToHSURL]
                                    withMapping:[BaseResponse jsonMapping]];

}


-(void)findFacebookFriends:(NSString*)accessToken
       withCompletionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    
    
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:accessToken forKey:@"socialtk"];
    [params setObject:[NSNumber numberWithInt:kSocialFriendFacebook] forKey:@"type"];

      [self postWithAction:[[ConfigManager sharedInstance]searchSocialUsersURL]
     params:params
     withHeaders:YES
     withToken:YES
     completionBlock:completion
     failureBlock:failure];
}

- (void)findUserByName:(NSDictionary*)searchDictionary
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    if (!searchDictionary) {
        searchDictionary=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    
    [self postWithAction:[[ConfigManager sharedInstance]searchHSUsersURL]
                  params:[searchDictionary mutableCopy]
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    

    
}


- (void)findUserByEmail:(NSDictionary*)searchDictionary
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    
    if (!searchDictionary) {
        searchDictionary=[NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    [self postWithAction:[[ConfigManager sharedInstance]searchHSUsersURL]
                  params:[searchDictionary mutableCopy]
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];

    
  
}


- (void)invitationSentViaEmail:(NSString*)hashedEmail
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue{
    self.requestQueue=queue;
    
    BaseResponse *response=[[BaseResponse alloc] init];
    response.errorCode=-1;
    completion(response);
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSNumber numberWithInt:kSocialFriendNotSocial] forKey:@"type"];
    [params setObject:hashedEmail forKey:@"id"];
    
    
    [self postWithAction:[[ConfigManager sharedInstance]inviteFriendToHSURL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
}

- (void)invitationSentViaFacebook:(NSString*)facebookId
                  completionBlock:(ROCompletionBlock)completion
                     failureBlock:(ROFailureBlock)failure
                            queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    BaseResponse *response=[[BaseResponse alloc] init];
    response.errorCode=-1;
    completion(response);
    
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:[NSNumber numberWithInt:kSocialFriendFacebook] forKey:@"type"];
    [params setObject:facebookId forKey:@"id"];
    
    
    [self postWithAction:[[ConfigManager sharedInstance]inviteFriendToHSURL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
}

@end









