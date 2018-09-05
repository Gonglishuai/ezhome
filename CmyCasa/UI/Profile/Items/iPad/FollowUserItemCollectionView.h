//
//  FollowUserItemCollectionView.h
//  Homestyler
//
//  Created by Yiftach Ringel on 20/06/13.
//
//

#import <UIKit/UIKit.h>
#import "FollowUserSingle.h"

@class FollowUserInfo;

@interface FollowUserItemCollectionView : UICollectionViewCell<ProfileCellUnifiedInitProtocol>

@property (nonatomic, strong) FollowUserInfo* followUserInfo;
@property (nonatomic, weak) id<FollowUserItemDelegate> delegate;

@end
