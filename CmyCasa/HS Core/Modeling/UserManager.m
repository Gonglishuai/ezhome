//
//  UserManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "UserManager.h"
#import "UserRO.h"
#import "BaseUserRO.h"
#import "HSErrorsManager.h"
#import "MessagesManager.h"
#import "UserLikesDO.h"
#import "HelpersRO.h"
#import "UserCombosResponse.h"
#import "UserComboDO.h"
#import "UserExtendedDetails.h"
#import "NotificationNames.h"
#import "WallpapersManager.h"
#import "FloortilesManager.h"
#import "ExternalLaunchManager.h"
#import "CatalogMenuLogicManger.h"
#import "WishlistHandler.h"

#import "ControllersFactory.h"

#import "ExternalLoginViewController.h"
#import "SHRNViewController.h"
#import "UserLoginBaseViewController.h"

@interface UserManager () <UserLogInDelegate> {
    
    BOOL bIsSilenceLoggInProcess;
    BOOL  bJumpingEnv;
    dispatch_queue_t globalQueue;
}


@property(nonatomic,strong) UserCombosResponse * userComboOptions;
@property (nonatomic, copy) UserLoginCompletionBlock userLoginCompletionBlock;

-(void)checkUserLoginIsSpecial:(NSString*)userType
            completionBlock:(HSCompletionBlock)completion
            queue:(dispatch_queue_t)queue;
- (void)getUserAllTypesLikes:(NSString*)userId
             completionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue;
-(BOOL)isSpecialUserCase:(NSString*)userType;
@end

@implementation UserManager

+ (instancetype)sharedInstance {
    static UserManager *sharedInstance = nil;
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        self.genericPreferences=[[UserSettingsPreferences alloc] init];
        [self loadUserInfo];
        bIsSilenceLoggInProcess = NO;
        globalQueue = dispatch_queue_create("com.autodesk.app.global", NULL);
    }
    return self;
}


- (Boolean) isSilenceLoggInProcess
{
    return bIsSilenceLoggInProcess;
}

- (void)setCurrentUser:(UserDO *)currentUser
{
    _currentUser = currentUser;
    [[MessagesManager sharedInstance] setupTimer];
}

- (void)showLoginFromViewController:(nonnull UIViewController*)fromViewController
                    eventLoadOrigin:(NSString *)loadOrigin
                      preLoginBlock:(nullable void(^)())preLoginBlock
                    completionBlock:(nullable UserLoginCompletionBlock)completionBlock {
    if ([[UserManager sharedInstance] isLoggedIn]) {
        if (completionBlock != nil)
            completionBlock(YES);
        return;
    }

    //If we are in the process of silent login, do nothing and wait for the process to end
    if ([[UserManager sharedInstance] isSilenceLoggInProcess]) {
//        if (completionBlock != nil)
//            completionBlock(YES);
        return;
    }

    if (![ConfigManager isAnyNetworkAvailable]) {
        [ConfigManager showMessageIfDisconnected];
        if (completionBlock != nil)
            completionBlock(NO);
        return;
    }

    if (preLoginBlock != nil)
        preLoginBlock();

    self.userLoginCompletionBlock = completionBlock;

    if ([ConfigManager isSignInSSOActive]) {
        SHRNViewController * loginViewController = [[SHRNViewController alloc] init];
        if (IS_IPAD) {
            [fromViewController.view addSubview:loginViewController.view];
            [fromViewController addChildViewController:loginViewController];
        } else {
//            [fromViewController presentViewController:loginViewController animated:YES completion:nil];
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
    }
    else if ([ConfigManager isSignInWebViewActive]) {
        if (IS_IPAD) {
            [ExternalLoginViewController showExternalLogin:fromViewController];
        } else {
            GenericWebViewBaseViewController * webViewController = [[UIManager sharedInstance] createGenericWebBrowser:[[ConfigManager sharedInstance] externalLoginUrl]];
            [fromViewController presentViewController:webViewController animated:YES completion:nil];
        }
    }
    else {
        UserLoginBaseViewController * loginViewController = nil;
        UINavigationController * navController = nil;
        if (IS_IPAD) {
            loginViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginViewController" inStoryboard:kLoginStoryboard];
        }
        else {
            navController = [ControllersFactory instantiateViewControllerWithIdentifier:@"UserLoginNavigator" inStoryboard:kLoginStoryboard];
            loginViewController = [[navController viewControllers] objectAtIndex:0];
        }

        loginViewController.eventLoadOrigin = loadOrigin;
        loginViewController.userLogInDelegate = self;
        loginViewController.openingType = eModal;
        if (navController != nil) {
            [fromViewController presentViewController:navController animated:YES completion:nil];
        } else {
            [fromViewController presentViewController:loginViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - UserLogInDelegate

- (void)loginRequestCanceled {
    if (self.userLoginCompletionBlock != nil) {
        self.userLoginCompletionBlock(NO);
    }
}

- (void)loginRequestEndedwithState:(BOOL)state {
    if (self.userLoginCompletionBlock != nil) {
        self.userLoginCompletionBlock(state);
    }
}


-(void)updateUserPushNotificationsWithStatus:(BOOL)isEnabled{
    
    
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [[[UserManager sharedInstance]genericPreferences] setReceiveingPushNotificationsEnabled:isEnabled forEmail:[[[UserManager sharedInstance]currentUser]userEmail]];
        
        if (isEnabled==NO)
          [[ExternalLaunchManager sharedInstance] unregisterSession:YES];
        else
          [[ExternalLaunchManager sharedInstance] registerWithSession];
    }else{
        
        [[[UserManager sharedInstance]genericPreferences] setReceiveingPushNotificationsEnabled:isEnabled forEmail:ANONIMUS_EMAIL_FORPN];
        if (isEnabled==NO) 
            [[ExternalLaunchManager sharedInstance]unregisterSession:NO];
        else
            [[ExternalLaunchManager sharedInstance] registerNoSession];
    }
}

-(void)updatePreference:(SettingsCellType)cellType withStatus:(BOOL)isEnabled{
    
    switch (cellType) {
        case kDataCollect:
            [[[UserManager sharedInstance]genericPreferences]setSendingAnalyticsEnabled:isEnabled];
            break;
            
        case kFBLikes:
            [UserSettingsPreferences setEnabledToParamWithKey:isEnabled andKey:kUserPreferenceFacebookLike];
            break;
            
        case kEmailsSend:
            [UserSettingsPreferences setEnabledToParamWithKey:isEnabled andKey:kUserPreferenceSendNewsletter];

            
            if ([[UserManager sharedInstance] isLoggedIn] == YES) {
                [[UserManager sharedInstance] userAcceptTermsAndAcceptEmails:isEnabled completionBlock:nil queue:globalQueue];
            }
            break;
            
        case kPushCell:
            [[UserManager sharedInstance] updateUserPushNotificationsWithStatus:isEnabled];
            break;
            
        default:
            break;
    }
}

-(NSString *)getSessionId {
   
    if (self.currentUser) {
        return self.currentUser.sessionId;
    }
    return nil;
}

- (NSString *)getLoggedInUserId {
    if (![self isLoggedIn])
        return nil;

    return self.currentUser.userID;
}

- (BOOL)isLoggedIn {
     if (!self.currentUser) {
         return NO;
     }

    switch (self.currentUser.usertype)
    {
        case kUserTypeWebLogin:
        case kUserTypePhone:
        case kUserTypeEmail:
            return self.currentUser.sessionId != nil;
        case kUserTypeFacebook:
//            return self.currentUser.sessionId != nil  && [FBSDKAccessToken currentAccessToken];
        default:
            break;
    }
}

- (BOOL)isCurrentUser:(NSString *)userId {
    if (![self isLoggedIn])
        return NO;

    return [self.currentUser.userID isEqual:userId];
}

-(void)loadUserInfo{
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"hs_user_info"]) {
        NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"hs_user_info"];
        self.currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    }
}

-(void)saveCurrentUserInfo{
    if ([UserManager sharedInstance].currentUser) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"hs_user_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)clearUserInfo{
    self.currentUser=nil;
    [[HCFacebookManager sharedInstance] clearUserInfo];
    [[[AppCore sharedInstance] getGalleryManager]clearPreviousUserLikesData];
    
    [self.genericPreferences clearUserInfo];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"hs_user_info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isUserInfoExists{
    return   self.currentUser==nil;
}

-(BOOL)isSpecialUserCase:(NSString*)userType{
    
    BOOL isSpecial=NO;
    if ([[ConfigManager sharedInstance] secondaryPlistUrls]!=nil && [[[ConfigManager sharedInstance] secondaryPlistUrls] isKindOfClass:[NSArray class]]) {
        
        for (int i=0; i<[[[ConfigManager sharedInstance] secondaryPlistUrls]count]; i++) {
            
            if ([[[[[ConfigManager sharedInstance] secondaryPlistUrls]objectAtIndex:i] objectForKey:@"utype"] intValue]==
                [userType intValue]) {
                isSpecial=YES;
                break;
            }
        }
    }
    return isSpecial;
}


-(void)checkUserLoginIsSpecial:(NSString*)userType
               completionBlock:(HSCompletionBlock)completion
                         queue:(dispatch_queue_t)queue{
    //check for all usertipes if there is different plist
    BOOL completionCalleNeeded = YES;
    if ([[ConfigManager sharedInstance] secondaryPlistUrls]!=nil && [[[ConfigManager sharedInstance] secondaryPlistUrls] isKindOfClass:[NSArray class]]) {
        
        for (int i=0; i<[[[ConfigManager sharedInstance] secondaryPlistUrls]count]; i++) {
            
            if ([[[[[ConfigManager sharedInstance] secondaryPlistUrls]objectAtIndex:i] objectForKey:@"utype"] intValue]==
                [userType intValue]) {
                bJumpingEnv = YES;
                
                NSString* version = [[[[ConfigManager sharedInstance] secondaryPlistUrls]objectAtIndex:i] objectForKey:@"version"];
                
                
                AppDelegate * deleg=[[UIApplication sharedApplication] delegate];
                completionCalleNeeded = NO;
                [deleg specialCaseLogin:version completionBlock:^(id serverResponse, id error) {
                    completion(serverResponse,error);
                } queue:queue];
               break;
            }
        }
    }
    if(completionCalleNeeded ){
        completion(nil,nil);
    }
}

#pragma mark- requests
- (void)userRegister:(NSString*)email
            withPass:(NSString*)password
              isProf:(BOOL)isProf
             withProf:(NSString*)profession
         agreeEmails:(BOOL)emailAgree
     completionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
    
    UserDO *tempUser=[[UserDO alloc] init];
    tempUser.userEmail=email;
    tempUser.allowEmails=emailAgree;
    tempUser.termsAccepted=YES;
    tempUser.isProfessional=isProf;
    tempUser.userProfession=profession;
    tempUser.usertype=kUserTypeEmail;
//    tempUser.userPassword=[HelpersRO encodeMD5:password];
    tempUser.userPassword=password;
    
    NSRange range=[email rangeOfString:@"@"];
    if (range.location!=NSNotFound) {
         tempUser.firstName=[email substringToIndex:range.location]; 
    }
  
    [[UserRO new] userRegister:tempUser.userEmail withPass:tempUser.userPassword isProf:isProf withProf:tempUser.userProfession agreeEmails:emailAgree completionBlock:^(id serverResponse) {
        
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode==-1) {
            tempUser.sessionId=respUser.sessionId;
            tempUser.userID=respUser.userID;
            tempUser.lastName=respUser.lastName;
            tempUser.userDescription=respUser.userDescription;
            self.currentUser=tempUser;
            
            //flurry
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SIGNUP_WITH_EMAIL];
//
//            [HSFlurry segmentIdentify:respUser isRegister:YES];
//            [HSFlurry logAnalyticEvent:EVENT_NAME_EMAIL_SIGNUP_CONFIRM withParameters:@{EVENT_PARAM_USER_ID:(respUser.userID)?respUser.userID:@""}];
            
            [UserSettingsPreferences setEnabledToParamWithKey:emailAgree andKey:kUserPreferenceSendNewsletter];
            
            if ([UserSettingsPreferences isUserForcedToDisablePushNotifications:respUser.userEmail]==NO) {
                [self.genericPreferences setReceiveingPushNotificationsEnabled:YES forEmail:respUser.userEmail];
                
            }
            
            [self saveCurrentUserInfo];
            [[ExternalLaunchManager sharedInstance]checkRegistration];  
            [[[AppCore sharedInstance]getProfsManager]updateMyFollowedProfessionalsWithCompletionBlock:nil queue:queue];
//            [[HomeManager sharedInstance] getMyFollowingWithCompletion:^{
//
//            } failureBlock:^(NSError *error) {
//
//            } queue:queue];

          
            if(completion) completion(serverResponse,nil);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusChanged"
                                                                object:nil];
        }else{
            if(completion) completion(nil,respUser.hsLocalErrorGuid);
        }
        
        [self segmentIOWithEmail];
        
    } failureBlock:^(NSError *error) {
        
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    
    } queue:queue];
   
}

-(void)postLoginActionsWithQueue:(dispatch_queue_t)queue
{
    //0. Refresh Blocked menu
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationUserDidLoginSuccessfully object:nil]];
    
    //1. Update settings preferences
    [UserSettingsPreferences setEnabledToParamWithKey:self.currentUser.allowEmails andKey:kUserPreferenceSendNewsletter];
    
    if ([UserSettingsPreferences isUserForcedToDisablePushNotifications:self.currentUser.userEmail]==NO) {
        [self.genericPreferences setReceiveingPushNotificationsEnabled:YES forEmail:self.currentUser.userEmail];
        
    }
    //2.0 send login success event before updating identity
//    [HSFlurry logAnalyticEvent:EVENT_NAME_USER_LOGIN_SUCCESS withParameters:
//      @{EVENT_PARAM_USER_TYPE:(self.currentUser.usertype==kUserTypeEmail)?EVENT_PARAM_VAL_USER_TYPE_REGULAR:EVENT_PARAM_VAL_USER_TYPE_FACEBOOK}];
//
//    //2.1 segment identity
//    [HSFlurry loggedInUserSetIdentity:self.currentUser.userID];
    
    //3. Push Notification registration
    [[ExternalLaunchManager sharedInstance]checkRegistration];
    
    //4. Get followed professionals
    [[[AppCore sharedInstance]getProfsManager]updateMyFollowedProfessionalsWithCompletionBlock:nil queue:queue];
    
    //5. Get User Likes
    [self getCurrentUserAllTypesLikesWithCompletionBlock:nil queue:queue];
    
    //6. Get User Following
    //[[HomeManager sharedInstance] getMyFollowingWithCompletion:nil failureBlock:nil queue:queue];
    
    //8. Notify that we can sync designs by alerting the network status
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserStatusChanged"
                                                        object:nil];
    
}

- (void)userLoginWithEmail:(NSString*)email
                  withPass:(NSString*)password
       isPassAlreadyHashed:(BOOL)isHashed
           completionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
    //clear previous User Data

    [self clearUserInfo];
    
    UserDO *tempUser=[[UserDO alloc] init];
    tempUser.userEmail=email;
    tempUser.usertype=kUserTypeEmail;
    if(isHashed)
        tempUser.userPassword=password;
    else
//        tempUser.userPassword=[HelpersRO encodeMD5:password]; // no encode from now on
        tempUser.userPassword=password;
    
    NSRange range=[email rangeOfString:@"@"];
    if (range.location!=NSNotFound) {
        tempUser.firstName=[email substringToIndex:range.location];
    }
    
    [[UserRO new] userLoginWithEmail:tempUser.userEmail withPass:tempUser.userPassword completionBlock:^(id serverResponse) {
        
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode==-1) {

            respUser.userPassword=tempUser.userPassword;
            respUser.usertype=kUserTypeEmail;
            respUser.userEmail=tempUser.userEmail;
            respUser.userProfession=tempUser.userProfession;
            self.currentUser=respUser;
            [self saveCurrentUserInfo];
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SUCCESSFUL_LOGIN];
            
            if ([self isSpecialUserCase:respUser.serverUserType]) {
                //check jumpers
                [self checkUserLoginIsSpecial:respUser.serverUserType completionBlock:^(id serverResponse, id error){
                    
                    
                    if(completion) completion(serverResponse,nil);
                    
                }queue:queue];
            }else{
                [self postLoginActionsWithQueue:queue];
                if(completion) completion(serverResponse,nil);
            }
            
//            [HSFlurry segmentIdentify:respUser isRegister:NO];
//
//            [HSFlurry logAnalyticEvent:EVENT_PARAM_SIGN_IN_EMAIL_SUCCESS];
            
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationUserDidFailLogin object:nil]];

            if(completion) completion(nil,respUser.hsLocalErrorGuid);
        }
        
        [self segmentIOWithEmail];
        
    } failureBlock:^(NSError *error) {
        
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
        
    } queue:queue];
}

- (void)userLoginWithPhone:(NSString *)phone withPass:(NSString *)password withToken:(NSString *)token
           completionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    if (token) {
        
        [[UserRO new] userLoginWithSSO:token completionBlock:^(id serverResponse){
            UserDO * respUser=(UserDO*)serverResponse;
            
            if ( respUser.errorCode==-1) {
                respUser.usertype=kUserTypePhone;
                respUser.userPhone = phone;
                respUser.userPassword = password;
                respUser.umsToken = token;
                self.currentUser=respUser;
                
                [self saveCurrentUserInfo];
                
                [self postLoginActionsWithQueue:queue];
                
            }
            
            if (completion) completion(serverResponse,nil);
        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            if (completion) completion(nil,erMessage);
        } queue:queue];
        
    } else {
        [[UserRO new] userLoginWithPhone:phone withPass:password completionBlock:^(id serverResponse){
            UserDO * respUser=(UserDO*)serverResponse;
            
            if ( respUser.errorCode==-1) {
                respUser.usertype=kUserTypePhone;
                respUser.userPhone = phone;
                respUser.userPassword = password;
                
                self.currentUser=respUser;
                
                [self saveCurrentUserInfo];
                
                [self postLoginActionsWithQueue:queue];
                
            }
            
            if (completion) completion(serverResponse,nil);
        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            if (completion) completion(nil,erMessage);
        } queue:queue];
    }


}

- (void)HomesylerfacebookLogin:(NSString*)facebookId fname:(NSString*)firstName lname:(NSString*)lastName email:(NSString*)email
                     profImage:(NSString*)profileImage  token:(NSString*)accessToken completionBlock:(HSCompletionBlock)completion
                         queue:(dispatch_queue_t)queue{
    UserDO *tempUser=[[UserDO alloc] init];
    tempUser.userEmail=email;
    tempUser.firstName=firstName;
    tempUser.lastName=lastName;
    tempUser.userProfileImage=profileImage;
    tempUser.usertype=kUserTypeFacebook;
    
    [[UserRO new] userLoginWithFacebook:accessToken completionBlock:^(id serverResponse) {
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode==-1) {
            respUser.usertype=kUserTypeFacebook;
            respUser.userEmail=email;
            respUser.firstName=firstName;
            respUser.lastName=lastName;
            respUser.userProfileImage=tempUser.userProfileImage;
            
            self.currentUser=respUser;
            
            [self saveCurrentUserInfo];
            
            [self postLoginActionsWithQueue:queue];
            
            if(completion) completion(serverResponse,nil);
            
            // Write to the log Facebook sign in successed
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SUCCESSFUL_LOGIN];
//
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SIGNIN_WITH_FACEBOOK];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationUserDidFailLogin object:nil]];

            if(completion) completion(nil,respUser.hsLocalErrorGuid);
            
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
        
    } queue:queue];
}

- (void)HomestylerWebLogin:(NSString*)identifier
                     fname:(NSString*)firstName
                     lname:(NSString*)lastName
                       email:(NSString*)email
                   profImage:(NSString*)profileImage
                       token:(NSString*)accessToken
             completionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue
{
    
    UserDO *tempUser=[[UserDO alloc] init];
    tempUser.userEmail = email;
    tempUser.firstName = firstName;
    tempUser.lastName = lastName;
    tempUser.usertype = kUserTypeWebLogin;
    tempUser.userProfileImage = profileImage;
    tempUser.webLoginExternalSessionId = accessToken;
    
    [[UserRO new] userLoginWithWebLogin:accessToken
                        completionBlock:^(id serverResponse)
    {
        UserDO * respUser=(UserDO*)serverResponse;
        
        if ( respUser.errorCode == -1)
        {
            respUser.usertype = kUserTypeWebLogin;
            respUser.userEmail = email;
            respUser.firstName = firstName;
            respUser.lastName = lastName;
            respUser.webLoginExternalSessionId = accessToken;
            self.currentUser = respUser;
            
            [self saveCurrentUserInfo];
            [self postLoginActionsWithQueue:queue];
            
            if(completion)
                completion(serverResponse,nil);
            
            // Write to the log WebLogin sign in successed
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SUCCESSFUL_LOGIN];
//            [HSFlurry logAnalyticEvent:EVENT_NAME_SIGNIN_WITH_WEBVIEW];
            
            //call
            if ([ConfigManager isWishListActive]) {
                [[CatalogMenuLogicManger sharedInstance] getWishListIdForEmail:^(id serverResponse, id error) {
                    
                    UserDO * user = [[UserManager sharedInstance] currentUser];
                    
                    [[WishlistHandler sharedInstance] getCompleteWishListsForEmail:user.userEmail
                                                               withCompletionBlock:^(id serverResponse, id error) {
                                                                   
                                                               }queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
                }];
            }
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationUserDidFailLogin object:nil]];
            
            if(completion)
                completion(nil,respUser.hsLocalErrorGuid);
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
        
    } queue:queue];
}

-(void)userLogoutWithCompletionBlock:(HSCompletionBlock)completion
                               queue:(dispatch_queue_t)queue{
   
    //clear server info for session
    [[UserRO new] userLogoutWithCompletionBlock:^(id serverResponse) {
        
        bIsSilenceLoggInProcess = NO;

       BaseResponse * respUser=(BaseResponse*)serverResponse;
            
        if ( respUser.errorCode==-1) {
            [[ExternalLaunchManager sharedInstance]unregisterSession:NO];
        }
    
        if (completion) {
            completion(serverResponse,nil);
            //clear local user info
            [self clearUserInfo];
        }
        
        [self segmentIOLogout];
        [[MessagesManager sharedInstance] destoryTimer];

    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
    } queue:queue];
}

- (void)userForgotPassword:(NSString*)email
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue{
    [[UserRO new] userForgotPassword:email completionBlock:^(id serverResponse) {
        
        
         if(completion) completion(serverResponse,nil);
        
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);

    } queue:queue];
}

- (void)userAcceptTermsAndAcceptEmails:(BOOL)acceptEmails
        completionBlock:(HSCompletionBlock)completion
                  queue:(dispatch_queue_t)queue{
    
    [[UserRO new] userAcceptTermsAndAcceptEmails:acceptEmails completionBlock:^(id serverResponse) {
        
        if(completion){
            BaseResponse * response=(BaseResponse*)serverResponse;
            
            if (response.errorCode==-1) {
                self.currentUser.allowEmails=acceptEmails;
                [self saveCurrentUserInfo];
                [UserSettingsPreferences setEnabledToParamWithKey:acceptEmails andKey:kUserPreferenceSendNewsletter];
            }
         
            completion(serverResponse,nil);
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
        
    } queue:queue];
    
}

- (void)updateUserInfoWithDO:(UserDO*)deltaUser
             completionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue{
    
    [[UserRO new] updateUserMetaData:deltaUser completionBlock:^(id serverResponse) {
        if(completion){
            BaseResponse * response=(BaseResponse*)serverResponse;
            
            if (response.errorCode==-1) {
                
                [self.currentUser updateLocalUserDataAfterMetaUpdate:deltaUser];
                [self saveCurrentUserInfo];
            }
            
            completion(serverResponse,nil);
        }

    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);

    } queue:queue];
}


- (void)updateUserPassword:(NSString*)newpassword
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue{

    if (self.currentUser.usertype == kUserTypePhone) {
    [[UserRO new] updatePasswordWithSSO:self.currentUser.userPassword newPassword:newpassword token:self.currentUser.umsToken completionBlock:^(id serverResponse) {
        if(completion){
            BaseResponse * response=(BaseResponse*)serverResponse;
            if (response.errorCode==-1) {
                //self.currentUser.userPassword=[HelpersRO encodeMD5:newpassword];
                self.currentUser.userPassword = newpassword;
                [self saveCurrentUserInfo];
                //[self userSilentLoginWithCompletionBlock:nil queue:queue];
            }
            completion(serverResponse,nil);
        }

    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
    } queue:queue];
    } else {
        UserDO * tempUser=[UserDO new];
        tempUser.userPassword = newpassword;
        //tempUser.userPassword=[HelpersRO encodeMD5:newpassword];
        [[UserRO new] updateUserMetaData:tempUser completionBlock:^(id serverResponse) {
            if(completion){
                BaseResponse * response=(BaseResponse*)serverResponse;
                if (response.errorCode==-1) {
                    //self.currentUser.userPassword=[HelpersRO encodeMD5:newpassword];
                    self.currentUser.userPassword = newpassword;
                    [self saveCurrentUserInfo];
                    //[self userSilentLoginWithCompletionBlock:nil queue:queue];
                }
                completion(serverResponse,nil);
            }
            
        } failureBlock:^(NSError *error) {
            NSString * erMessage=[error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion) completion(nil,errguid);
        } queue:queue];
    }
}

- (void)getUserAllTypesLikes:(NSString*)userId
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue{

    [[UserRO new] getUserLikes:userId withType:kLikeAllItems completionBlock:^(id serverResponse) {
       
        if(completion){
            completion(serverResponse,nil);
        }

        
      
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
    } queue:queue];
     
}


- (void)getCurrentUserAllTypesLikesWithCompletionBlock:(HSCompletionBlock)completion
                                                 queue:(dispatch_queue_t)queue{
    
    
    NSString * userid=[[self currentUser] userID];
    
    [self getUserAllTypesLikes:userid completionBlock:^(id serverResponse, id error) {
        
        
        if (error==nil) {
            UserLikesDO * reponse=(UserLikesDO*)serverResponse;
            if (reponse && [reponse isKindOfClass:[UserLikesDO class]]) {
               [[[AppCore sharedInstance] getGalleryManager]handleUserLikesData:reponse.designs];
            }
        }
        
        
        if (completion) {
            completion(serverResponse,error);
        }
      
        
    } queue:queue];
                       
    
}

- (void)getUserLikedArticles:(NSString*)userId
              completionBlock:(HSCompletionBlock)completion
                        queue:(dispatch_queue_t)queue{
    
    
    [[UserRO new] getUserLikes:userId withType:kLikeArticleItems completionBlock:^(id serverResponse) {
       
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response) {
            if(completion  && response.errorCode==-1){
                completion(serverResponse,nil);
            
            }else if(completion){
                    completion(nil,response.hsLocalErrorGuid);
                }
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
    } queue:queue];
}

-(void)userSilentLoginWithCompletionBlock:(HSCompletionBlock) completion queue:(dispatch_queue_t)queue{
    
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:kNotificationSilentLoginWillBegin object:nil]];
    
    // Clean cached data
    //[[WallpapersManager sharedInstance] clearData];
    //[[FloortilesManager sharedInstance] clearData];
    
    if( bIsSilenceLoggInProcess ==YES && bJumpingEnv == NO)
    {
        return;
    }
    
    void (^simpleBlock)(void)= ^(){
        
        BaseResponse * response=[[BaseResponse alloc] init];
        response.errorCode=0;
        [[UIMenuManager sharedInstance] refreshMenu];
        bIsSilenceLoggInProcess = NO;
        bJumpingEnv = NO;
        completion(response,nil);
    };
    
    if (self.currentUser==nil) {
        dispatch_async(queue,simpleBlock);
        return;
    }
    
    UserType loginType = [[self currentUser]usertype] ;
    bIsSilenceLoggInProcess = YES;
    
    switch (loginType)
    {
        case kUserTypePhone:
        {
            NSString* phone = [[self currentUser] userPhone];
            NSString* password = [[self currentUser]userPassword] ;
            if (phone == nil || password == nil)
            {
                dispatch_async(queue,simpleBlock);
                return ;
            }
            
            [self userLoginWithPhone:phone withPass:password withToken:nil completionBlock:^(id serverResponse,id error) {
                
                bIsSilenceLoggInProcess = NO;
                bJumpingEnv = NO;
                [[UIMenuManager sharedInstance] refreshMenu];
                
                if(completion)completion(serverResponse, error);
                
            } queue:queue];
        }; break;
        /* Perform Email registration silent Sign In */
        case kUserTypeEmail:
        {
            NSString* email = [[self currentUser] userEmail];
            NSString* password = [[self currentUser]userPassword] ;
            if (email == nil || password == nil)
            {
                dispatch_async(queue,simpleBlock);
                return ;
            }
            
            [self userLoginWithEmail:email withPass:password isPassAlreadyHashed:NO completionBlock:^(id serverResponse, id error) {
                
                bIsSilenceLoggInProcess = NO;
                bJumpingEnv = NO;
                [[UIMenuManager sharedInstance] refreshMenu];
                
                if(completion)completion(serverResponse,error);
                
            } queue:queue];
        }; break;
        
        /* Perform Facebook silent Sign In */
        case kUserTypeFacebook:
        {
//            dispatch_async(dispatch_get_main_queue(), ^(){
//
//                if ([FBSDKAccessToken currentAccessToken]) {
//                    NSLog(@"LogedIn");
//                    [[HCFacebookManager sharedInstance] populateUserDetails];
//                }else{
//                    bIsSilenceLoggInProcess = NO;
//                    [[UIMenuManager sharedInstance] refreshMenu];
//                    
//                    dispatch_async(queue,simpleBlock);
//                }
//            });
        }; break;
            
        /* Perform WebLogin silent Sign In */
        case kUserTypeWebLogin:
        {
            [self HomestylerWebLogin:[[self currentUser] userID]
                               fname:[[self currentUser] firstName]
                               lname:[[self currentUser] lastName]
                               email:[[self currentUser] userEmail]
                           profImage:nil
                               token:[[self currentUser] webLoginExternalSessionId]
                     completionBlock:^(id serverResponse, id error) {
                         
                         bIsSilenceLoggInProcess = NO;
                         bJumpingEnv = NO;
                         [[UIMenuManager sharedInstance] refreshMenu];
                         
                         if(completion)completion(serverResponse,error);
                         
                     }
                               queue:queue];
        } break;
            
        default:
            break;
    }
}

- (void)getUserComboOptionsWithCompletionBlock:(HSCompletionBlock)completion
                                         queue:(dispatch_queue_t)queue{
    
    
    if (self.userComboOptions && completion) {
        completion(self.userComboOptions,nil);
        return;
    }
    
    [[BaseUserRO new] getUserCombosWithcompletionBlock:^(id serverResponse) {
        UserCombosResponse * response=(UserCombosResponse*)serverResponse;
        
        if (response) {
            //store combo options
            self.userComboOptions=response;
            
            if(completion  && response.errorCode==-1){
                completion(serverResponse,nil);
                
            }else if(completion){
                completion(nil,response.hsLocalErrorGuid);
            }
        }
        
  
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage=[error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) completion(nil,errguid);
    } queue:queue];
}

#pragma mark- NSUDID
-(NSString*)getUniqueDeviceUserIdentifier{
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"unique_user_device_id"]) {
       NSString *uuid = [[NSUUID UUID] UUIDString];
        if (uuid) {
            [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:@"unique_user_device_id"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return uuid;
        }      
    }else{
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"unique_user_device_id"];
    }
    
    return nil;
}

- (void)updateUserDOWithUserProfile:(UserProfile *)profile {

    if(profile){
        self.currentUser.extendedDetails=[profile.extendedDetails copy];
       UserDO * deltaUser= [profile generateUserDOFromProfile];

        //this
        [self.currentUser updateLocalUserDataAfterMetaUpdate:deltaUser];
    }
}

- (BOOL)checkIfModeller {
    
    RETURN_ON_NIL([[ConfigManager sharedInstance] modellersUserEmail], NO);
    RETURN_ON_NIL([[UserManager sharedInstance] currentUser], NO);
    
    NSString *currentMail = [[UserManager sharedInstance] currentUser].userEmail;
    NSString *modellersMails = [[ConfigManager sharedInstance] modellersUserEmail];
    NSArray *mails = [modellersMails componentsSeparatedByString:@","];
    
    for (NSString *mail in mails) {
        if ([[mail lowercaseString] isEqualToString:[currentMail lowercaseString]])
            return YES;
    }
    
    return NO;
}

#pragma mark - SEGMENT
-(void)segmentIOWithEmail{
    //segment.io
    BOOL isFirstSignIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"is_first_login"] boolValue];
    if (!isFirstSignIn) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"is_first_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    [HSFlurry segmentTrack:@"sign in" withParameters:@{@"first sign in" : isFirstSignIn ? @"YES" : @"NO"}];
//    [HSFlurry segmentTrack:@"sign in" withParameters:@{@"medium" : @"email"}];
}

-(void)segmentIOWithFacebook{
    //segment.io
    BOOL isFirstSignIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"is_first_login"] boolValue];
    if (!isFirstSignIn) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"is_first_login"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
//    [HSFlurry segmentTrack:@"sign in" withParameters:@{@"first sign in" : isFirstSignIn ? @"YES" : @"NO"}];
//    [HSFlurry segmentTrack:@"sign in" withParameters:@{@"medium" : @"facebook"}];
}

-(void)segmentIOLogout{
    //segment.io
    
//    [HSFlurry segmentTrack:@"log out" withParameters:nil];
    
}

@end






