//
//  NotificationNames.h
//  Homestyler
//
//  Created by Ma'ayan on 11/13/13.
//
//

#ifndef Homestyler_NotificationNames_h
#define Homestyler_NotificationNames_h

#pragma mark - Notifications

/*
 Fires when a MyDesignDO item changed status.
 User info contains the item id (NSString) for the key kNotificationItemId.
*/
#define kNotificationMyDesignDOStatusChanged            @"_kNotificationMyDesignDOStatusChanged"

/*
 Fires when a LikeDesignDO item changed status.
 User info contains the item id (NSString) for the key kNotificationItemId.
 */
#define kNotificationLikeDesignDOLikeStatusChanged      @"_kNotificationLikeDesignDOLikeStatusChanged"

/*
 This notification calls when a "my design" ass been added/updated etc.
 */
#define kNotificationMyHomeDesignsNeedRefresh           @"_kNotificationMyHomeDesignsNeedRefresh"

/*
 Gets called when the downloading of the initial bulk of comments for a certain item has finished.
 */
#define kNotificationGetCommentsFinished                @"_kNotificationGetCommentsFinished"

/*
 Gets called when a previous request to post a comment had returned.
 */
#define kNotificationAddCommentFinished                 @"_kNotificationAddCommentFinished"

/*
 Gets called after a login action had been completed successfully
 */
#define kNotificationUserDidLoginSuccessfully           @"_kNotificationUserDidLoginSuccessfully"

/*
 Gets called whenever a login attempt fails
 */

#define kNotificationUserDidFailLogin                   @"_kNotificationUserDidFailLogin"

/*
 Gets called right before a silent login proccess is about to begin
 */
#define kNotificationSilentLoginWillBegin               @"_kNotificationSilentLoginWillBegin"


#pragma mark - General Keys

#define kNotificationKeyItemId                          @"itemId"

#define kNotificationKeyUserId                          @"userId"

/*
 Sent from Full screen when like action done to update gallery stream
 */
#define kNotificationLikeActionSuccessfullyDone         @"LikeActionSuccessfullyDoneNotification"


/*
 Gets called whenever a logout
 */

#define kNotificationUserDidLogout              @"_kNotificationUserDidLogout"

/*
 * Design Manager Change
 */

#define kNotificationDesignManagerChanged              @"_kNotificationDesignManagerChanged"


#define kNotificationAssetLikeStatusChanged         @"_kNotificationAssetLikeStatusChanged"

#define kNotificationUserFollowingStatusChanged     @"_kNotificationUserFollowingStatusChanged"

#endif
