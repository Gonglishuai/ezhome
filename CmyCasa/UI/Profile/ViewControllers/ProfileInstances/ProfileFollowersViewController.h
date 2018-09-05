//
// Created by Berenson Sergei on 12/23/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProfileInstanceBaseViewController.h"
#import "FollowUserSingle.h"

@interface ProfileFollowersViewController : ProfileInstanceBaseViewController< ProfilePageCollectionDelegate>

@property(nonatomic,assign)id<FollowUserItemDelegate,ProfileInstanceDataDelegate,ProfileCountersDelegate> rootFollowDelegate;

- (void)addOrRemoveFollowUser:(FollowUserInfo *)info andFollowStatus:(BOOL)follow;

@end