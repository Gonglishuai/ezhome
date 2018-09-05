//
//  SocialManager.h
//  Cheerz
//
//  Created by Amir baranes on 9/9/13.
//  Copyright (c) 2013 Zemingo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSocialServices.h"
#import "HSSharingConstants.h"
#import "HSShareObject.h"

@protocol SocialManagerSharingDelegate <NSObject>

@optional
- (void)shareToSocialNetworkType:(HSSocialNetworkType)type didFailWithError:(NSString *)errorString;
- (void)didFinishShareToSocialNetworkType:(HSSocialNetworkType)type;
- (void)didFinishLoginWithAccessTokenNetworkType:(HSSocialNetworkType)type;
@end

typedef void (^TwitterNativePostCompletionBlock)(void);
typedef void (^TwitterFailBlock)(NSString *errorDescription);
typedef void (^TwitterLoginBlock)(void);
typedef void (^TwitterAuthBlock)(BOOL);

@interface HSSocialManager : NSObject

@property (nonatomic ,weak) UIViewController * viewController;


+ (id)sharedSocialManager;
- (void)setupFacebookDelegate:(id<SocialManagerSharingDelegate>)delegate;
- (BOOL)canShareType:(HSSocialNetworkType)type;
- (void)tryLoginToType:(HSSocialNetworkType)type withCompletion:(HSCompletionBlock)completion;
- (void)loginWithFacebookWithComplition:(FacebookLoginSuccessBlock)successBlock onFailure:(FacebookLoginFailBlock)failBlock;
- (void)shareText:(HSShareObject*)shareObj fromViewController:(UIViewController *)viewController withDelegate:(id <SocialManagerSharingDelegate>)delegate;
- (void)postToFacebookWithLink:(HSShareObject*)shareObj onCompletion:(SocialPostCompletionBlock)completionBlock onFailure:(SocialPostFailBlock)failBlock;
- (void)canShareWithTwitter:(TwitterAuthBlock)complition;

@end


