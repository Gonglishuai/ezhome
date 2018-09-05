//
//  ProfileProtocols.h
//  Homestyler
//
//  Created by Avihay Assouline on 1/12/14.
//
//

#import <Foundation/Foundation.h>
#include "UserDO.h" // for enum UserViewField

///////////////////////////////////////////////////////
// ENUMS
///////////////////////////////////////////////////////
typedef enum {
    ProfileEditProfileViewer = -3,
    ProfileTaUnvisibleProfileViewer = -2,
    ProfileTabUnknown = -1,
    ProfileTabActivities = 0,
    ProfileTabDesign = 1,
    ProfileTabProfessionals = 2,
    ProfileTabArticles = 3,
    ProfileTabFollowers = 4,
    ProfileTabFollowing = 5,
} ProfileTabs;

///////////////////////////////////////////////////////
// @protocol: ProfileDelegate
// @description:
///////////////////////////////////////////////////////
@protocol ProfileDelegate <NSObject>

- (void)profileSignOutPressed;

@end

///////////////////////////////////////////////////////
// @protocol: ProfileInstanceDataDelegate
// @description:
///////////////////////////////////////////////////////
@class UserProfile;

@protocol ProfileInstanceDataDelegate <NSObject>

-(NSString*)getUserIDForCurrentProfile;
-(UserProfile*)getUserProfileObject;
@end

///////////////////////////////////////////////////////
// @protocol: ProfileUserDetailsDelegate
// @description:
///////////////////////////////////////////////////////
@class UserDO;

@protocol ProfileUserDetailsDelegate <NSObject>

@optional
-(void)changePasswordRequested;
-(void)changeUserProfileImageRequestedForRect:(UIView*)mview;
-(void)askToLeaveWithoutSave;
-(void)askToLeaveWithSaveAction;
-(UIView*)getParentView;
-(void)valueChangedTo:(id)nVal forField:(UserViewField)field;
-(void)adjustViewForFieldInput:(CGRect)fieldRect;
-(void)adjustViewForField:(UITableViewCell*)cell;
-(void)restoreViewForFieldInput;
-(void)leaveProfileEditingWithoutChanges;
-(void)leaveProfileEditingWithSaveChanges:(UserDO *)deltaUser;
-(BOOL)updateOrGetCurrentLocation;
-(void)openUserWebPage:(NSString*)url;
-(void)openOptionsForField:(UserViewField)field withCurrentValue:(id)value openView:(UIView*)mview;
-(void)signoutRequested;
@end

///////////////////////////////////////////////////////
// @protocol: ProfileCountersDelegate
// @description:
///////////////////////////////////////////////////////
@protocol ProfileCountersDelegate <NSObject>
- (void)updateProfileCounterString:(NSString*)value ForTab:(ProfileTabs)tab;
- (void)updateProfileCounter:(int)value ForTab:(ProfileTabs)tab;
- (NSString *)getProfileCounterValueFor:(ProfileTabs)tab;
@optional
-(void)increaseProfileCounterForTab:(ProfileTabs)tab;
-(void)decreaseProfileCounterForTab:(ProfileTabs)tab;
@end


///////////////////////////////////////////////////////
// @protocol: DesignItemDelegate
// @description:
///////////////////////////////////////////////////////
typedef void(^PreDesignLikeBlock)();
typedef void(^DesignLikeCompletionBlock)(NSString * _Nullable designId, BOOL success);

@protocol DesignItemDelegate <NSObject>
@optional
- (void)designPressed:(DesignBaseClass*)design;
- (void)designEditPressed:(MyDesignDO*)design;

- (void)showDesignDetailById:(nonnull NSString *)designId;
- (void)toggleLikeStateForDesign:(nonnull DesignBaseClass *)design
                  withLikeButton:(nonnull UIButton *)likeButton
                  preActionBlock:(nullable PreDesignLikeBlock)preActionBlock
                 completionBlock:(nullable DesignLikeCompletionBlock)completionBlock;
- (void)shareDesign:(nonnull DesignBaseClass *)design withDesignImage:(nonnull UIImage *)designImage;
- (void)showUserProfile:(nonnull NSString *)userId;

@end

///////////////////////////////////////////////////////
// @protocol: ArticleItemDelegate
// @description:
///////////////////////////////////////////////////////
@protocol ArticleItemDelegate <NSObject>

- (void)articlePressed:(GalleryItemDO*)article fromArticles:(NSArray*)allArticles;

@end


///////////////////////////////////////////////////////
// @protocol: ProfileUserInfoDelegate
// @description:
///////////////////////////////////////////////////////
@protocol ProfileUserInfoDelegate
- (void)openSignInDialog;
- (void)editProfile;
- (void)showFollowing;
- (void)showFollowers;
- (void)showLikesToast;
@end

///////////////////////////////////////////////////////
// @protocol: FollowUserItemDelegate
// @description:
///////////////////////////////////////////////////////
typedef void(^PreFollowUserBlock)(NSString * _Nullable userId);
typedef void(^FollowUserCompletionBlock)(NSString * _Nullable userId, BOOL success);

@class FollowUserInfo;
@protocol FollowUserItemDelegate <NSObject>

@optional
- (void)userPressed:(FollowUserInfo*)info;
- (void)followPressed:(FollowUserInfo*)info
            didFollow:(BOOL)follow;

- (void)showUserProfile:(FollowUserInfo*)userInfo;
- (void)followUser:(FollowUserInfo*)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock
            sender:(nullable UIView *)sender;
@end

///////////////////////////////////////////////////////
// @protocol: ActivityTableCellDelegate
// @description:
///////////////////////////////////////////////////////
@protocol ActivityTableCellDelegate <NSObject>

- (void)openPhotoFullScreen:(NSString *)designId;
- (void)openUserProfilePage:(NSString *)profileId;
- (void)openDesignFullScreen:(NSString *)designId;
- (void)openFullScreen:(NSString*)designId withType:(ItemType)type;
- (void)openArticleFullScreen:(NSString*)articleId;
- (void)followUser:(FollowUserInfo *)followUser;
- (void)unfollowUser:(NSString*)followUserId;
- (void)openHelpEmailPage;
- (UIViewController *)delegateViewController;
- (BOOL)isCurrentCellOfLoggedInUser;

@end

///////////////////////////////////////////////////////
// @protocol: LikeDesignDelegate
// @description:
///////////////////////////////////////////////////////
@protocol LikeDesignDelegate <NSObject>
@optional
- (void)performLikeForItemId:(NSString *)itemId withItemType:(ItemType)itemType likeState:(BOOL)isLiked sender:(UIViewController *)sender shouldUsePushDelegate:(BOOL)shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion;
- (BOOL) performLikeForItem:(DesignBaseClass*)item likeState:(BOOL) isLiked sender:(UIViewController*) sender  shouldUsePushDelegate:(BOOL) shouldUsePush andCompletionBlock:(void(^)(BOOL success))completion;

@end

///////////////////////////////////////////////////////
// @protocol: CommentDesignDelegate
// @description:
///////////////////////////////////////////////////////
@protocol CommentDesignDelegate <NSObject>

- (void)openCommentScreenForDesign:(NSString *)designId withType:(ItemType)type;

@optional
- (NSString *)getCommentForActivityId:(NSString *)strId timestamp:(NSTimeInterval)ts;
- (void)commentBox:(UITextView *)commentBox didStartEditingAtCell:(UITableViewCell *)cell;
- (void)commentCelldidFinishWritingCommnet:(NSString *)comment forActivityId:(NSString *)actId;

@end

