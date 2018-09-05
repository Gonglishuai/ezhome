//
//  HCFacebookManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/31/13.
//
//

#import "HCFacebookManager.h"
//#import <Analytics/SEGAnalytics.h>
#import "AppDelegate.h"
#import "social/Social.h"
#import "accounts/Accounts.h"
#import "NotificationAdditions.h"
#import "UserBaseFriendDO.h"
#import "SocialFriendDO.h"

@interface HCFacebookManager (){
    
    UIViewController * returnPresentedController;
    NSDictionary* userGraph;
}

@end

@implementation HCFacebookManager

static HCFacebookManager *sharedInstance = nil;


+ (HCFacebookManager *)sharedInstance {
   
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[HCFacebookManager alloc] init];
        sharedInstance.facebookFriendsList = [NSMutableArray arrayWithCapacity:0];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        
        NSMutableDictionary * dict = [[ConfigManager sharedInstance] getMainConfigDict];
        userGraph = nil;
        
        NSString* link=@"";
        NSString* name=@"";
        NSString* caption=@"";
        NSString* description=@"";
        
        if(dict){
            
            NSDictionary * url = [[dict objectForKey:@"share"] objectForKey:@"url"];
            if(url)
            {
                link=[url objectForKey:@"link"];
                name=@"Autodesk Homestyler";
                caption=link;
                description = [NSString stringWithFormat:NSLocalizedString(@"post_description_field",@""), [ConfigManager getAppName]];
                
            }
        }
    }
    return self;
}

-(BOOL)isFacebookSessionOpen{
//    if ([FBSDKAccessToken currentAccessToken]) {
//        return YES;
//    }else{
//        return NO;
//    }
}

#pragma mark-
#pragma mark Facebook Login
- (void)populateUserDetails
{
//    if ([FBSDKAccessToken currentAccessToken]) {
//        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
//                                           parameters:@{@"fields" : @"first_name,last_name,picture,id,email"}]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 NSLog(@"fetched user:%@", result);
//                 
//                 userGraph = [result copy];
//                 
//                 [self loginWithHomestylerAfterFBLogin];
//             }
//         }];
//        
//    }else{
//        userGraph = nil;
//    }
}


-(void)loginWithHomestylerAfterFBLogin
{
//    NSString * profileImage = @"";
//    if ([userGraph objectForKey:@"picture"] &&
//        [[userGraph objectForKey:@"picture"] objectForKey:@"data"] &&
//        [[[userGraph objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"])
//    {
//        profileImage = [[[userGraph objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
//
//        if ([[userGraph objectForKey:@"id"] length]>0) {
//            profileImage = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",[userGraph objectForKey:@"id"]];
//        }
//    }
//
//    [[UserManager sharedInstance] HomesylerfacebookLogin:[userGraph objectForKey:@"id"]
//                                               fname:[userGraph objectForKey:@"first_name"]
//                                               lname:[userGraph objectForKey:@"last_name"]
//                                               email:[userGraph objectForKey:@"email"]
//                                               profImage:profileImage
//                                               token:[[FBSDKAccessToken currentAccessToken] tokenString]
//    completionBlock:^(id serverResponse, id error) {
//
//        if (!error) {
//            UserDO * respUser = (UserDO*)serverResponse;
//
//            if(respUser.errorCode == -1 && respUser.termsAccepted == NO)
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:@"SinginFacebookCompleteNotification" object:respUser]];
//
//                [self segmentIdentify:respUser];
//
//                [HSFlurry logAnalyticEvent:EVENT_NAME_FACEBOOK_SIGNUP_CONFIRM withParameters:@{EVENT_PARAM_USER_ID:(respUser.userID)?respUser.userID:@""}];
//            }else{
//
//                //successful facebook login on homestyler
//                [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:@"SinginFacebookCompleteNotification" object:nil]];
//            }
//        }else{
//            //get the error and check for terms
//            //failed to facebook login
//            [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:[NSNotification notificationWithName:@"SinginFacebookFailedCompleteNotification" object:nil]];
//        }
//
//
//    } queue:dispatch_get_main_queue()];
}

-(void)clearUserInfo{
    userGraph = nil;
}

#pragma mark- Like on behalf of user
-(void)facebookLikeDesign:(NSString*)designId
                  andType:(NSString*)dtype
      withCompletionBlock:(HSCompletionBlock)completion
                    queue:(dispatch_queue_t)queue{
   
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_likes"]) {
//
//        NSString * shareLink = [[ConfigManager sharedInstance] generateFacebookLikeLink:designId withType:dtype];
//
//
//        FBSDKGraphRequest *requestLikes = [[FBSDKGraphRequest alloc]
//                                           initWithGraphPath:@"me/likes"
//                                           parameters:@{@"object" : shareLink}];
//        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
//        [connection addRequest:requestLikes
//             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//
//                 if (error) {
//                     NSString * erMessage=NSLocalizedString(@"facebook_friends_empty_copy", @"");
//                     NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_FAILED_FB_LIKE] withPrevGuid:nil];
//
//#ifdef USE_FLURRY
//                     if(ANALYTICS_ENABLED){
//
//                         NSArray * objs=[NSArray arrayWithObjects:shareLink, nil];
//                         NSArray * keys=[NSArray arrayWithObjects:@"share_link" ,nil];
//
//                         [HSFlurry logEvent:FLURRY_FACEBOOK_LIKE_FAILED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
//
//                     }
//#endif
//                     if(completion) completion(nil,errguid);
//                 }else{
//                     NSDictionary * dict=(NSDictionary*)result;
//                     NSString * likeID = [dict objectForKey:@"id"];
//
//#ifdef USE_FLURRY
//                     if(ANALYTICS_ENABLED){
//
//                         NSArray * objs = [NSArray arrayWithObjects:shareLink, nil];
//                         NSArray * keys = [NSArray arrayWithObjects:@"share_link" ,nil];
//                         [HSFlurry logEvent:FLURRY_FACEBOOK_LIKE_SUCCESS withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
//                     }
//#endif
//
//                     if(completion)
//                         completion(likeID,nil);
//                 }
//
//        }];
//    }
}

#pragma mark - SEGMENT
-(void)segmentIdentify:(UserDO *)user{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    [dict setObject:user.userEmail forKey:@"email"];
    [dict setObject:user.firstName forKey:@"firstName"];
    [dict setObject:user.lastName forKey:@"lastName"];

//    [[SEGAnalytics sharedAnalytics] identify:user.userID traits:dict];
}


@end
