//
//  UserRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "UserRO.h"
#import "UserDO.h"
#import "ESLoginAPI.h"

NSString *const UserLoginFacebookRegisterString = @"fb";

@implementation UserRO

+(void)initialize{
    
      
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]REGISTER_URL]
                                    withMapping:[UserDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]LOGIN_URL]
                                    withMapping:[UserDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getSSOLogin]
                                    withMapping:[SSODO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getSSOPassword]
                                    withMapping:[PasswordDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionUpdateProfile]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionFollow]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionMyProfile]
                                    withMapping:[UserProfile jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] FORGOT_PASS_URL]
                                    withMapping:[BaseResponse jsonMapping]];

    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] acceptTermsURL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] LOGOUT_URL]
                                    withMapping:[BaseResponse jsonMapping]];
}


- (void)userRegister:(NSString*)email
            withPass:(NSString*)password
              isProf:(BOOL)isProf
            withProf:(NSString*)profession
         agreeEmails:(BOOL)emailAgree
     completionBlock:(ROCompletionBlock)completion
        failureBlock:(ROFailureBlock)failure
               queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString* pro = isProf ? @"true" : @"false";
    NSString* emailAgr = emailAgree ? @"true" : @"false";
    
    
    [params setObject:email forKey:@"e"];
    [params setObject:password forKey:@"p"];
    [params setObject:pro forKey:@"pro"];
    [params setObject:emailAgr forKey:@"allowEmails"];
    [params setObject:@"IOS" forKey:@"device"];
     
    [self postWithAction:[[ConfigManager sharedInstance]REGISTER_URL]
                       params:params
                  withHeaders:NO
               withToken:YES
              completionBlock:completion
                 failureBlock:failure];
}

- (void)userLoginWithEmail:(NSString*)email
         withPass:(NSString*)password
  completionBlock:(ROCompletionBlock)completion
     failureBlock:(ROFailureBlock)failure
    queue:(dispatch_queue_t)queue{
    
 
    self.requestQueue=queue;
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    
    [params setObject:email forKey:@"e"];
    [params setObject:password forKey:@"p"];
    [params setObject:@"s" forKey:@"m"];
    [params setObject:@"IOS" forKey:@"device"];
    
    [self postWithAction:[[ConfigManager sharedInstance]LOGIN_URL]
                  params:params
             withHeaders:NO
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}


- (void)userLoginWithFacebook:(NSString*)accessToken
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue{
    
    
    self.requestQueue = queue;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:accessToken forKey:@"at"];
    [params setObject:UserLoginFacebookRegisterString forKey:@"m"];
    [params setObject:@"IOS" forKey:@"device"];
    
    [self postWithAction:[[ConfigManager sharedInstance] LOGIN_URL]
                  params:params
             withHeaders:NO
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)userLoginWithWebLogin:(NSString*)accessToken
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:accessToken forKey:@"at"];
    [params setObject:[[ConfigManager sharedInstance] UserLoginWebLoginRegisterString] forKey:@"m"];
    [params setObject:@"IOS" forKey:@"device"];
    
    [self postWithAction:[[ConfigManager sharedInstance] LOGIN_URL]
                  params:params
             withHeaders:NO
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)userLoginWithPhone:(NSString*)phone
                  withPass:(NSString*)password
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;

    [ESLoginAPI loginUserName:phone password:password loginImageCodeKey:@"" userLoginImageCodeValue:@"" andSuccess:^(NSDictionary *dictionary) {

        SHLog(@"登录 成功 %@",dictionary);

        [[ESLoginManager sharedManager] loginComplete:dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:phone forKey:@"Account"];

        [self userLoginWithSSO:dictionary[@"accessToken"] completionBlock:completion failureBlock:failure queue:queue];
        
    } andFailure:^(NSError *error) {

    }];
}
    
- (void)updatePasswordWithSSO:(NSString*)oldPass
                  newPassword:(NSString*)newPass
                        token:(NSString*)accessToken
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:oldPass forKey:@"oldClearTextPassword"];
    [params setObject:newPass forKey:@"newClearTextPassword"];
    
    NSDictionary *headers = @{@"X-Token": accessToken};
    [self putWithAction:[[ConfigManager sharedInstance] getSSOPassword]
                 params:params
                headers:headers
              withToken:NO
        completionBlock:^(id serverResponse){
                 if (completion)
                 completion(serverResponse);

             }
           failureBlock:failure];
}

- (void)userLoginWithSSO:(NSString*)accessToken
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
                   queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:accessToken forKey:@"umstoken"];
    [params setObject:@"IOS" forKey:@"device"];
    
    [self postWithAction:[[ConfigManager sharedInstance] LOGIN_URL]
                  params:params
             withHeaders:NO
               withToken:YES
         completionBlock:^(id serverResponse){
             UserDO * respUser = (UserDO*)serverResponse;
             if (respUser.errorCode==-1) {
                 respUser.umsToken = accessToken;
             }
             if (completion)
                completion(serverResponse);
         }
            failureBlock:failure];
}
    
- (void)userLogoutWithCompletionBlock:(ROCompletionBlock)completion
                         failureBlock:(ROFailureBlock)failure
                                queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [self postWithAction:[[ConfigManager sharedInstance]LOGOUT_URL]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)updateUserMetaData:(UserDO*)updatedUsers
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue
{
    self.requestQueue=queue;
    
    NSMutableDictionary* params = [updatedUsers generateUpdateJsonDictionary];
   
    [self postWithAction:[[ConfigManager sharedInstance] actionUpdateProfile]
                  params:params
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
}

- (void)userForgotPassword:(NSString*)email
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue{
    
    
    self.requestQueue=queue;
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:email forKey:@"e"];
    
    
    
    [self postWithAction:[[ConfigManager sharedInstance]FORGOT_PASS_URL]
                  params:params
             withHeaders:NO
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)followUser:(NSString*)userId
            follow:(BOOL)follow
   completionBlock:(ROCompletionBlock)completion
      failureBlock:(ROFailureBlock)failure
                queue:(dispatch_queue_t)queue
{
    
    if (userId==nil) {
        failure(nil);
        return;
    }

    self.requestQueue=queue;
    [self postWithAction:[[ConfigManager sharedInstance] actionFollow]
                  params:[@{@"followId": userId,
                          @"actionType": (follow ? @"follow" : @"unfollow"),
                          @"s" : [[UserManager sharedInstance] getSessionId]
                            } mutableCopy]
             withHeaders:YES
               withToken:YES
         completionBlock:completion failureBlock:failure];
    
}

- (void)userAcceptTermsAndAcceptEmails:(BOOL)acceptEmails
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    [self postWithAction:[[ConfigManager sharedInstance] acceptTermsURL]
                  params:[@{
                          @"allowEmails": (acceptEmails ? @"true" : @"false")} mutableCopy]
             withHeaders:YES
               withToken:YES
         completionBlock:completion
            failureBlock:failure];
    
}

#pragma mark-
#pragma mark- Base class overrides
- (void)getUserProfileById:(NSString*)userId
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue
{
 
    
    
    if ([[UserManager sharedInstance] getSessionId]==nil) {
        failure(nil);
        return;
    }
    self.requestQueue=queue;
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionMyProfile]
                       params:[@{@"sk": [[UserManager sharedInstance] getSessionId]} mutableCopy]
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
}

@end
