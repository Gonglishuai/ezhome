//
//  FollowUserSingle.h
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import <UIKit/UIKit.h>
#import "FollowUserInfo.h"
#import "ProfilePageBaseViewController.h"
#import "ProfileProtocols.h"

@interface FollowUserSingle :  UICollectionViewCell<ProfileCellUnifiedInitProtocol>


@property (nonatomic, strong) FollowUserInfo* followUserInfo;

@property (nonatomic, weak) id<FollowUserItemDelegate> delegate;

@end
