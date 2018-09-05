//
//  HSSocialManager.m
//  Cheerz
//
//  Created by Amir baranes on 9/9/13.
//  Copyright (c) 2013 Zemingo. All rights reserved.
//

#import "HSSocialManager.h"
//#import <TwitterKit/TwitterKit.h>

// Post dialog
#define kFacebookPostParamLink                              @"link"
#define kFacebookPostParamPictureUrl                        @"picture"
#define kFacebookPostParamName                              @"name"
#define kFacebookPostParamCaption                           @"caption"
#define kFacebookPostParamDescription                       @"description"
#define kFacebookPostParamMessage                           @"message"

@interface HSSocialManager()
{
    BOOL isFacebookRequestPending;
}

@property (nonatomic ,strong) HSSocialServices *socialServices;
@property (nonatomic, weak) id <SocialManagerSharingDelegate> pinDelegate;
@property (nonatomic, weak) id <SocialManagerSharingDelegate> facebookDelegate;

@end

@implementation HSSocialManager
@synthesize socialServices = _socialServices;

+ (id)sharedSocialManager
{
    static dispatch_once_t onceToken;
    static HSSocialManager *sharedSocialManager = nil;
    
    dispatch_once(&onceToken, ^
                  {
                      sharedSocialManager = [[HSSocialManager alloc] init];
                  });
    
    return sharedSocialManager;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.socialServices = [[HSSocialServices alloc] init];
        isFacebookRequestPending = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleComingBackFromBackground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)setupFacebookDelegate:(id<SocialManagerSharingDelegate>)delegate{
    self.facebookDelegate=delegate;
}

- (void)handleComingBackFromBackground
{
    if (isFacebookRequestPending)
    {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(failFacenookPendingRequest) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)failFacenookPendingRequest
{
    if (isFacebookRequestPending)
    {
        if ((self.facebookDelegate != nil) && ([self.facebookDelegate respondsToSelector:@selector(shareToSocialNetworkType:didFailWithError:)]))
        {
            [self.facebookDelegate shareToSocialNetworkType:HSSocialNetworkTypeFacebook didFailWithError:@""];
        }
    }
}

- (BOOL)canShareType:(HSSocialNetworkType)type
{
    if (type == HSSocialNetworkTypeFacebook){
        return [self isLoggedInToFacebook];
        
    }else if (type == HSSocialNetworkTypeTwitter){
        return [self isLoggedInToTwitter];

    }
    
    return NO;
}

- (void)tryLoginToType:(HSSocialNetworkType)type withCompletion:(HSCompletionBlock)completion
{
    if (type == HSSocialNetworkTypeFacebook)
    {
        [self loginWithFacebookWithComplition:^{
                if (completion) {
                    completion(nil,nil);
                }
         }
          onFailure:^(NSString *errorDescription)
         {
             if (completion) {
                 completion(nil,@"");
             }
         }];
    }
    else if (type == HSSocialNetworkTypeTwitter)
    {
        [self loginWithTwitterWithComplition:^{
            if (completion) {
                completion(nil,nil);
            }
        }];
    }
}

- (void)shareText:(HSShareObject*)shareObj fromViewController:(UIViewController *)viewController withDelegate:(id <SocialManagerSharingDelegate>)delegate

{
    SocialPostCompletionBlock (^successBlockWithType) (HSSocialNetworkType type) = ^(HSSocialNetworkType type)
    {
        SocialPostCompletionBlock successBlock = ^
        {
            if ((delegate != nil) && ([delegate respondsToSelector:@selector(didFinishShareToSocialNetworkType:)]))
            {
                [delegate didFinishShareToSocialNetworkType:type];
            }
        };
        
        return successBlock;
    };
    
    SocialPostFailBlock (^failureBlockWithType) (HSSocialNetworkType type) = ^(HSSocialNetworkType type)
    {
        SocialPostFailBlock failureBlock = ^ (NSString *errorDescription)
        {
            if ((delegate != nil) && ([delegate respondsToSelector:@selector(shareToSocialNetworkType:didFailWithError:)]))
            {
                [delegate shareToSocialNetworkType:type didFailWithError:errorDescription];
            }
        };
        
        return failureBlock;
    };
    
    if (shareObj.type == HSSocialNetworkTypeFacebook)
    {
        if ([self isLoggedInToFacebook])
        {
            [self postToFacebookWithLink:shareObj onCompletion:successBlockWithType(HSSocialNetworkTypeFacebook) onFailure:failureBlockWithType(HSSocialNetworkTypeFacebook)];
        }
        else
        {
            [self tryLoginToType:HSSocialNetworkTypeFacebook withCompletion:^(id serverResponse, id error) {
                
                if ([self isLoggedInToFacebook])
                {
                  [self postToFacebookWithLink:shareObj onCompletion:successBlockWithType(HSSocialNetworkTypeFacebook) onFailure:failureBlockWithType(HSSocialNetworkTypeFacebook)];
                    
                }else{
                    failureBlockWithType(HSSocialNetworkTypeFacebook);
                }

            }];
        }
    }
    else if (shareObj.type == HSSocialNetworkTypeTwitter)
    {
        [self canShareWithTwitter:^(BOOL authorized) {
            if (authorized) {
                [self tweetUsingTWRequestWithInitialText:[NSString stringWithFormat:@"%@\n%@",shareObj.designShareLinkOriginal,shareObj.message] image:shareObj.picture andURL:nil onCompletion:successBlockWithType(HSSocialNetworkTypeTwitter) onFailure:failureBlockWithType(HSSocialNetworkTypeTwitter)];
            } else {
                [self tryLoginToType:HSSocialNetworkTypeTwitter withCompletion:^(id serverResponse, id error) {
                    if (error == nil) {
                        [self tweetUsingTWRequestWithInitialText:[NSString stringWithFormat:@"%@\n%@",shareObj.designShareLinkOriginal,shareObj.message] image:shareObj.picture andURL:nil onCompletion:successBlockWithType(HSSocialNetworkTypeTwitter) onFailure:failureBlockWithType(HSSocialNetworkTypeTwitter)];
                    } else {
                        failureBlockWithType(HSSocialNetworkTypeTwitter);
                    }
                }];
            }
        }];
    }
}

#pragma mark - Facebook

- (BOOL)isLoggedInToFacebook
{
//    if ([FBSDKAccessToken currentAccessToken]) {
//        return YES;
//    }else{
//        return NO;
//    }
}

- (BOOL)isLoggedInToTwitter
{
    return YES;
}

- (void)loginWithFacebookWithComplition:(FacebookLoginSuccessBlock)successBlock onFailure:(FacebookLoginFailBlock)failBlock
{
//    isFacebookRequestPending = YES;
//
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//    [login
//     logInWithReadPermissions:@[@"email"]
//     fromViewController:_viewController
//     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//         if (error) {
//             NSLog(@"Process error");
//             isFacebookRequestPending = NO;
//             failBlock([error description]);
//         } else if (result.isCancelled) {
//             NSLog(@"Cancelled");
//             isFacebookRequestPending = NO;
//             failBlock([error description]);
//         } else {
//             NSLog(@"Logged in");
//             isFacebookRequestPending = NO;
//             successBlock();
//         }
//     }];
}

- (void)postToFacebookWithLink:(HSShareObject*)shareObj
                  onCompletion:(SocialPostCompletionBlock)completionBlock
                     onFailure:(SocialPostFailBlock)failBlock
{

    isFacebookRequestPending = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (shareObj.designShareLinkOriginal.length)
    {
        [params setObject:shareObj.designShareLinkOriginal forKey:kFacebookPostParamLink];
    }else if (shareObj.designShareLink.length)
    {
        [params setObject:shareObj.designShareLink forKey:kFacebookPostParamLink];
    }
     if (shareObj.pictureURL.absoluteString.length)
    {
        [params setObject:shareObj.pictureURL.absoluteString forKey:kFacebookPostParamPictureUrl];
    }
    
    if (shareObj.name.length)
    {
        [params setObject:shareObj.name forKey:kFacebookPostParamName];
    }
    
    if (shareObj.caption.length)
    {
        [params setObject:shareObj.caption forKey:kFacebookPostParamCaption];
    }
    
    if (shareObj._description.length)
    {
        [params setObject:shareObj._description forKey:kFacebookPostParamDescription];
    }
    
    if ([shareObj getSharingMessage].length)
    {
        [params setObject:[shareObj getSharingMessage] forKey:kFacebookPostParamMessage];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self publishToFeedWithParams:params withCompletionBlock:completionBlock andFailBlock:failBlock];
    });
}

- (void)publishToFeedWithParams:(NSDictionary *)params withCompletionBlock:(SocialPostCompletionBlock)completionBlock andFailBlock:(SocialPostFailBlock)failBlock
{
//    isFacebookRequestPending = NO;
//
//    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
//        [[[FBSDKGraphRequest alloc]
//          initWithGraphPath:@"me/feed"
//          parameters:params
//          HTTPMethod:@"POST"]
//         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//             if (!error) {
//                 NSLog(@"Post id:%@", result[@"id"]);
//                 completionBlock();
//             }else{
//                failBlock([[error userInfo] description]);
//             }
//         }];
//    } else {
//        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//        [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result,NSError *error)
//         {
//             if (error) {
//                 NSLog(@"publish permission granted error");
//                 failBlock([error description]);
//             } else if (result.isCancelled) {
//                 NSLog(@"publish permission granted Cancelled");
//                 failBlock([error description]);
//             } else {
//                 [[[FBSDKGraphRequest alloc]
//                   initWithGraphPath:@"me/feed"
//                   parameters:params
//                   HTTPMethod:@"POST"]
//                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                      if (!error) {
//                          NSLog(@"Post id:%@", result[@"id"]);
//                          completionBlock();
//                      }else{
//                          failBlock([[error userInfo] description]);
//                      }
//                  }];
//             }
//         }];
//    }
}

#pragma mark - Twitter

- (void)canShareWithTwitter:(TwitterAuthBlock)complition
{
//    TWTRSession *lastSession = [[[Twitter sharedInstance] sessionStore] session];
//    if (lastSession == nil)
//    {
//        complition(NO);
//    }
//
//    NSError *error;
//
//    NSString *accout = @"https://api.twitter.com/1.1/account/verify_credentials.json";
//
//    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:lastSession.userID];
//
//    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:accout parameters:@{} error:&error];
//
//    [client sendTwitterRequest:request completion:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
//        if (error)
//        {
//            complition(NO);
//        }
//        else
//        {
//            complition(YES);
//        }
//
//    }];
}

- (void)loginWithTwitterWithComplition:(TwitterLoginBlock)complition
{
//    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
//        if (session) {
//            [[[Twitter sharedInstance] sessionStore] saveSession:session
//                                                      completion:^(id<TWTRAuthSession>  _Nullable session, NSError * _Nullable error) {
//                if (complition) {
//                    complition();
//                }
//            }];
//        } else {
//            if (complition) {
//                complition();
//            }
//        }
//    }];
}

- (void)tweetUsingTWRequestWithInitialText:(NSString *)initialText image:(UIImage *)image andURL:(NSURL *)url onCompletion:(TwitterNativePostCompletionBlock)completionBlock onFailure:(TwitterFailBlock)failBlock
{
//    TWTRSession *lastSession = [[Twitter sharedInstance] sessionStore].session;
//    if (lastSession)
//    {
//        NSError *error;
//
//        NSString *media = @"https://upload.twitter.com/1.1/media/upload.json";
//
//        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
//
//        NSString *imageString = [imageData base64EncodedStringWithOptions:0];
//
//        TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:lastSession.userID];
//
//        NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:media parameters:@{@"media":imageString} error:&error];
//
//        [client sendTwitterRequest:request completion:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
//
//            // Post tweet With media_id
//
//            if (error == nil)
//            {
//                NSError *jsonError;
//                NSDictionary *json = [NSJSONSerialization
//                                      JSONObjectWithData:data
//                                      options:0
//                                      error:&jsonError];
//                NSString *mediaId = [json objectForKey:@"media_id_string"];
//
//                NSString *update = @"https://api.twitter.com/1.1/statuses/update.json";
//
//                NSURLRequest * request = [client URLRequestWithMethod:@"POST" URL:update parameters:@{@"status": initialText, @"media_ids": mediaId} error:&error];
//
//                [client sendTwitterRequest:request completion:^(NSURLResponse *urlResponse, NSData *data, NSError *error) {
//
//                    if (error == nil) {
//                        if (completionBlock)
//                        {
//                            completionBlock();
//                        }
//                    } else {
//                        if (failBlock)
//                        {
//                            failBlock(NSLocalizedString(@"Tweet failed", nil));
//                        }
//                    }
//
//                }];
//            }
//            else
//            {
//                if (failBlock)
//                {
//                    failBlock(NSLocalizedString(@"Tweet failed", nil));
//                }
//            }
//        }];
//    }
}

-(void)tweetWithNativeShareDialogFromViewController:(UIViewController *)sender withInitialText:(NSString *)initialText image:(UIImage *)image andURL:(NSURL *)url onCompletion:(TwitterNativePostCompletionBlock)completionBlock onFailure:(TwitterFailBlock)failBlock
{
//    TWTRComposer *composer = [[TWTRComposer alloc] init];
//
//    [composer setText:initialText];
//    [composer setImage:image];
//    [composer setURL:url];
//
//    // Called from a UIViewController
//    [composer showFromViewController:sender completion:^(TWTRComposerResult result) {
//
//        [sender dismissViewControllerAnimated:YES completion:^
//         {
//             switch (result)
//             {
//                 case TWTRComposerResultCancelled:
//                 {
//                     if (failBlock)
//                     {
//                         failBlock(NSLocalizedString(@"User cancelled", nil));
//                     }
//                 }
//                 break;
//
//                 case TWTRComposerResultDone:
//                 {
//                     if (completionBlock)
//                     {
//                         completionBlock();
//                     }
//                 }
//                 break;
//
//                 default:
//                 break;
//             }
//         }];
//    }];

//    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//
//    [controller setInitialText:initialText];
//
//    if (url != nil)
//    {
//        [controller addURL:url];
//    }
//
//    if (image != nil)
//    {
//        [controller addImage:image];
//    }
//
//    controller.completionHandler = ^(TWTweetComposeViewControllerResult result)
//    {
//        [sender dismissViewControllerAnimated:YES completion:^
//         {
//             switch (result)
//             {
//                 case TWTweetComposeViewControllerResultCancelled:
//
//                 {
//                     if (failBlock)
//                     {
//                         failBlock(NSLocalizedString(@"User cancelled", nil));
//                     }
//                 }
//                     break;
//
//                 case TWTweetComposeViewControllerResultDone:
//
//                 {
//                     if (completionBlock)
//                     {
//                         completionBlock();
//                     }
//                 }
//                     break;
//
//                 default:
//                     break;
//             }
//         }];
//    };
//
//    [sender presentViewController:controller animated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
