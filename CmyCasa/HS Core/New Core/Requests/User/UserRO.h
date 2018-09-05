//
//  UserRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "BaseRO.h"
#import "BaseUserRO.h"

FOUNDATION_EXPORT NSString *const UserLoginFacebookRegisterString;

@interface UserRO : BaseUserRO

- (void)userRegister:(NSString*)email
            withPass:(NSString*)password
            isProf:(BOOL)isProf
            withProf:(NSString*)profession
            agreeEmails:(BOOL)emailAgree
            completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
            queue:(dispatch_queue_t)queue;

- (void)userLoginWithEmail:(NSString*)email
            withPass:(NSString*)password
            completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
            queue:(dispatch_queue_t)queue;

- (void)userLoginWithFacebook:(NSString*)accessToken
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue;

- (void)userLoginWithPhone:(NSString*)phone
                  withPass:(NSString*)password
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
                   queue:(dispatch_queue_t)queue;
    
- (void)updatePasswordWithSSO:(NSString*)oldPass
                  newPassword:(NSString*)newPass
                        token:(NSString*)accessToken
                  completionBlock:(ROCompletionBlock)completion
                     failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue;

- (void)userLoginWithSSO:(NSString*)accessToken
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
                   queue:(dispatch_queue_t)queue;

- (void)userLogoutWithCompletionBlock:(ROCompletionBlock)completion
                         failureBlock:(ROFailureBlock)failure
                                queue:(dispatch_queue_t)queue;

- (void)userLoginWithWebLogin:(NSString*)accessToken
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue;

- (void)userForgotPassword:(NSString*)email
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue;

- (void)updateUserMetaData:(UserDO*)updatedUsers
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;

- (void)followUser:(NSString*)userId
            follow:(BOOL)follow
   completionBlock:(ROCompletionBlock)completion
      failureBlock:(ROFailureBlock)failure
             queue:(dispatch_queue_t)queue;


- (void)userAcceptTermsAndAcceptEmails:(BOOL)acceptEmails
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue;

@end
