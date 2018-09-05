//
//  UserManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "BaseManager.h"
#import "UserDO.h"
#import "UserSettingsPreferences.h"
#import "LoginDefs.h"


@interface UserManager : BaseManager


+ (instancetype) sharedInstance;

@property(nonatomic,strong)UserDO * currentUser;
@property(nonatomic,strong)UserSettingsPreferences * genericPreferences;


- (NSString *)getSessionId;

- (NSString *)getLoggedInUserId;

- (BOOL)isLoggedIn;
- (BOOL)isCurrentUser:(NSString *)userId;

-(void)loadUserInfo;
-(void)saveCurrentUserInfo;
-(void)clearUserInfo;
-(BOOL)isUserInfoExists;

- (Boolean) isSilenceLoggInProcess;

-(NSString*)getUniqueDeviceUserIdentifier;

- (void)showLoginFromViewController:(nonnull UIViewController*)fromViewController
                    eventLoadOrigin:(NSString *)loadOrigin
                      preLoginBlock:(nullable void(^)())preLoginBlock
                    completionBlock:(UserLoginCompletionBlock)completionBlock;

#pragma mark- requests

- (void)getUserComboOptionsWithCompletionBlock:(HSCompletionBlock)completion
               queue:(dispatch_queue_t)queue;



-(void)userLogoutWithCompletionBlock:(HSCompletionBlock)completion
                               queue:(dispatch_queue_t)queue;



- (void)userForgotPassword:(NSString*)email
     completionBlock:(HSCompletionBlock)completion
               queue:(dispatch_queue_t)queue;



- (void)userRegister:(NSString*)email
            withPass:(NSString*)password
              isProf:(BOOL)isProf
            withProf:(NSString*)profession
         agreeEmails:(BOOL)emailAgree
     completionBlock:(HSCompletionBlock)completion
    queue:(dispatch_queue_t)queue;

- (void)HomesylerfacebookLogin:(NSString*)facebookId fname:(NSString*)firstName lname:(NSString*)lastName email:(NSString*)email
                          profImage:(NSString*)profileImage  token:(NSString*)accessToken completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;

- (void)HomestylerWebLogin:(NSString*)identifier
                     fname:(NSString*)firstName
                     lname:(NSString*)lastName
                     email:(NSString*)email
                 profImage:(NSString*)profileImage
                     token:(NSString*)accessToken
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;

- (void)userLoginWithEmail:(NSString*)email
                  withPass:(NSString*)password
            isPassAlreadyHashed:(BOOL)isHashed
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;

- (void)userLoginWithPhone:(NSString *)phone
                  withPass:(NSString *)password
                 withToken:(NSString *)token
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;

- (void)userAcceptTermsAndAcceptEmails:(BOOL)acceptEmails
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;


- (void)updateUserInfoWithDO:(UserDO*)deltaUser
                    completionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue;

- (void)updateUserPassword:(NSString*)newpassword
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;


- (void)getUserLikedArticles:(NSString*)userId
             completionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue;


- (void)getCurrentUserAllTypesLikesWithCompletionBlock:(HSCompletionBlock)completion
                                                 queue:(dispatch_queue_t)queue;


-(void)userSilentLoginWithCompletionBlock:(HSCompletionBlock) completion queue:(dispatch_queue_t)queue;


-(void)updateUserPushNotificationsWithStatus:(BOOL)isEnabled;
-(void)updatePreference:(SettingsCellType)cellType withStatus:(BOOL)isEnabled;

- (void)updateUserDOWithUserProfile:(UserProfile *)profile;

- (BOOL)checkIfModeller;

- (void)destoryTimer;

- (void)receiveUserMessages;

- (void)postLoginActionsWithQueue:(dispatch_queue_t)queue;
@end


