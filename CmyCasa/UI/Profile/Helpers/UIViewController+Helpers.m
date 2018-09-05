//
//  UIViewController+Helpers.m
//  Homestyler
//
//  Created by Yiftach Ringel on 23/06/13.
//
//

#import "UIViewController+Helpers.h"

@implementation UIViewController (Helpers)

- (UIAlertView*)showErrorWithMessage:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:message
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                                         otherButtonTitles: nil];
    [alert show];
    return alert;
}

- (UIAlertView*)showErrorWithMessageWithoutDelegate:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                                         otherButtonTitles: nil];
    [alert show];
    return alert;
}

- (BOOL)isConnectionAvailable
{
    if (![ConfigManager isAnyNetworkAvailableOrOffline])
    {
        [self showErrorWithMessage:NSLocalizedString(@"failed_action_no_network_found_start", @"You seem to be offline. Please check your internet connection and retry.")];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)isModal {

    if (self.presentingViewController==nil) {
        return false;
    }
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}


@end
