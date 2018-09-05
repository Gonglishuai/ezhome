//
//  ProfileFollowingsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileInstanceBaseViewController.h"
#import "FollowUserSingle.h"

@interface ProfileFollowingsViewController : ProfileInstanceBaseViewController< ProfilePageCollectionDelegate>

// Follow delta
@property (strong, nonatomic) NSMutableArray* followingRemove;
@property (nonatomic,assign) id<FollowUserItemDelegate,ProfileInstanceDataDelegate,ProfileCountersDelegate> rootFollowDelegate;

- (void)addOrRemoveFollowUser:(FollowUserInfo *)info andFollowStatus:(BOOL)follow;


@end
