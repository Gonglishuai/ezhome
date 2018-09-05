//
//  HSSocialServices.h
//
//  Created by Stav Ashuri on 12/2/12.
//  Copyright (c) 2012 Stav Ashuri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSShareObject.h"

#define kSocialManagerBackgroundQueueName "com.HSSharing.backgroundQueue"

#define kFacebookFeedDialogDefaultCaption       NSLocalizedString(@"Home Styler", nil)
#define kFacebookFeedDialogDefaultDescription   @""


//Permissions
#define kInitialPermissions nil
#define kFacebookPermissionsPublishAction   @"publish_actions" //Never ask for this together with read permissions

typedef void (^FacebookLoginSuccessBlock)(void);
typedef void (^FacebookInviteCompletionBlock)(void);
typedef void (^FacebookFriendsSuccessBlock)(NSArray *arrayOfFriends);
typedef void (^FacebookVerifyFriendshipSuccessBlock)(BOOL isFriend);
typedef void (^SocialPostCompletionBlock)(void);
typedef void (^FacebookFeedDialogPostCompletionBlock)(NSString *postId);
typedef void (^FacebookNativePostCompletionBlock)(NSString *postId);
typedef void (^FacebookProfileImageUrlCompletionBlock) (NSURL *imageUrl);
typedef void (^FacebookPostToFriendCompletionBlock)(NSString *postId);
typedef void (^FacebookPublishPermissionsCompletionBlock)(NSString *newToken);

typedef void (^SocialPostFailBlock)(NSString *errorDescription);
typedef void (^FacebookLoginFailBlock)(NSString *errorDescription);


@class FBGraphUser;

#pragma mark - Interface
@interface HSSocialServices : NSObject


//Facebook
- (void)cleanCache;

@end
