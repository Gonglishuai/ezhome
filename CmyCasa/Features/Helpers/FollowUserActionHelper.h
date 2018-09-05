//
//  FollowUserActionHelper.h
//  Homestyler
//
//  Created by Eric Dong on 05/09/18.
//
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"

@interface FollowUserActionHelper : NSObject

- (void)followUser:(nonnull FollowUserInfo *)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock
hostViewController:(nonnull UIViewController *)hostViewController
            sender:(nullable UIView *)sender;

@end
