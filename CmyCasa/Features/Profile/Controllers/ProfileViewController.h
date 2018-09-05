//
//  ProfileViewController.h
//  EZHome
//
//  Created by Eric Dong on 03/27/18.
//

#import <UIKit/UIKit.h>
//#import <GAITrackedViewController.h>

#import "ProfileProtocols.h"

#import "ProfileCollectionViewHeader.h"

//GAITrackedViewController
@interface ProfileViewController : UIViewController <
ProfileInstanceDataDelegate,
ProfileUserInfoDelegate,
ProfileUserDetailsDelegate,
ProfileCountersDelegate,
ProfileCollectionViewHeaderDelegate,
DesignItemDelegate,
MyDesignEditDelegate,
FollowUserItemDelegate>

@property (strong, nonatomic)   NSString*           userId;
@property (weak, nonatomic)     id<ProfileDelegate> delegate;

@property (assign,nonatomic) ProfileViewDisplayMode currentMode;
@property (assign,nonatomic) ProfileViewDataType currentType;

// User Info
@property (strong, nonatomic) UserProfile* userProfile;
@property (nonatomic, assign) BOOL isCurrentUserProfile;
@property (nonatomic, assign) BOOL isShowSystemIcon;

@property (nonatomic, strong) MyDesignDO *tempDesignPressed;

@property (nonatomic) CGFloat collectionViewCellMargin;
@property (nonatomic) CGFloat backgroundImageAspect;

@end
