//
//  ProfileCollectionViewCell_UserInfo.h
//  EZHome
//
//  Created by xiefei on 5/3/18.
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"

@interface ProfileCollectionViewCell_UserInfo : UICollectionViewCell

@property (nonatomic, weak) id<ProfileUserInfoDelegate, FollowUserItemDelegate> delegate;
@property (nonatomic, strong) UserProfile * userProfile;

+ (CGFloat)calcExtraUserInfoHeightForUser:(UserProfile *)userProfile withCellWidth:(CGFloat)cellWidth;

- (CGRect)getUserAvatarImageViewFrame;
- (CGRect)getFollowButtonFrame;

@end
