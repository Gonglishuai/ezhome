//
//  ProfileUserListViewCell.h
//  EZHome
//
//  Created by Eric Dong on 04/12/18.
//

#import <UIKit/UIKit.h>
#import "ProfileProtocols.h"

@interface ProfileUserListViewCell : UICollectionViewCell

@property (nonatomic, weak) id<FollowUserItemDelegate> delegate;
@property (nonatomic, strong) FollowUserInfo *userInfo;

@end

@interface ProfileUserListViewEmptyCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
