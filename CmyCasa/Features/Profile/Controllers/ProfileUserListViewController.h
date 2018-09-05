//
//  ProfileUserListViewController.h
//  Homestyler
//
//  Created by Eric Dong on 04/12/2018.
//

#ifndef ProfileUserListViewController_h
#define ProfileUserListViewController_h

#import <UIKit/UIKit.h>
//#import <GAITrackedViewController.h>

#import "ProfileUserListBase.h"

@interface ProfileUserListViewController : UIViewController <FollowUserItemDelegate>

@property (nonatomic, strong) ProfileUserListBase * dataSource;

@end

#endif /* ProfileUserListViewController_h */
