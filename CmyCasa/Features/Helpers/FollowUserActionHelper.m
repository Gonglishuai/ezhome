//
//  FollowUserActionHelper.m
//  Homestyler
//
//  Created by Eric Dong on 05/09/18.
//
//

#import "FollowUserActionHelper.h"

#import "UserManager.h"
#import "HomeManager.h"

#import "FlurryDefs.h"

@interface FollowUserActionHelper ()

@property (nonatomic, weak) UIViewController * hostViewController;

@end

@implementation FollowUserActionHelper

- (void)followUser:(nonnull FollowUserInfo *)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock
hostViewController:(nonnull UIViewController *)hostViewController
            sender:(nullable UIView *)sender {
    self.hostViewController = hostViewController;

    if (!follow) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"unfollow_user", @""), [userInfo getUserFullName]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *unfollowAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"unfollow", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self followUser:userInfo follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") style:UIAlertActionStyleCancel handler:nil];

        [alert addAction:unfollowAction];
        [alert addAction:cancelAction];

        if (IS_IPAD) {
            [alert setModalPresentationStyle:UIModalPresentationFormSheet];

            UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
            popPresenter.sourceView = sender;
            popPresenter.sourceRect = sender.bounds;
        }

        [self.hostViewController presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self followUser:userInfo follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
}

- (void)followUser:(FollowUserInfo *)userInfo
            follow:(BOOL)follow
    preActionBlock:(nullable PreFollowUserBlock)preActionBlock
   completionBlock:(nullable FollowUserCompletionBlock)completionBlock {
    __weak typeof(self) weakSelf = self;

    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UserManager sharedInstance] showLoginFromViewController:self.hostViewController
                                                  eventLoadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOW
                                                    preLoginBlock:^{
//                                                        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:
//                                                         @{EVENT_PARAM_SIGNUP_TRIGGER: EVENT_PARAM_VAL_FOLLOW_USER,
//                                                           EVENT_PARAM_NAME_LOAD_ORIGIN:EVENT_PARAM_VAL_LOAD_ORIGIN_FOLLOW}];
                                                    }
                                                  completionBlock:^(BOOL success) {
                                                      if (success && weakSelf != nil) {
                                                          [weakSelf followUser:userInfo follow:follow preActionBlock:preActionBlock completionBlock:completionBlock];
                                                      }
                                                  }];
        return;
    }

    NSString * userId = userInfo.userId;

    if (preActionBlock != nil)
        preActionBlock(userId);

    [[HomeManager sharedInstance] followUser:userInfo.userId
                                      follow:follow
                              withCompletion:^(id serverResponse) {
                                  BaseResponse * response = (BaseResponse *)serverResponse;
                                  BOOL success = (response != nil && response.errorCode == -1);
                                  if (completionBlock != nil) {
                                      completionBlock(userId, success);
                                  }
                              }
                                failureBlock:^(NSError * err) {
                                    if (completionBlock != nil) {
                                        completionBlock(userId, NO);
                                    }
                                }
                                       queue:nil];
}

@end

