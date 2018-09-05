//
//  NotificationsActionHelper.m
//  Homestyler
//
//  Created by liuyufei on 5/9/18.
//

#import "NotificationsActionHelper.h"
#import "ControllersFactory.h"
#import "MessagesManager.h"

@implementation NotificationsActionHelper

- (void)showBubbleView:(BubbleViewType)bubbleViewType
        withSourceView:(nonnull UIView *)sourceView
 withNotificationsInfo:(nonnull NSArray *)info
    fromViewController:(nonnull UIViewController *)hostViewController
{
    if (info.count == 0)
        return;

    CGRect frame = [hostViewController.view convertRect:sourceView.frame fromView:sourceView.superview];
    BubbleEffectView *bubbleView = [[BubbleEffectView alloc] initWithFrame:frame sourceView:sourceView];
    bubbleView.bubbleViewType = bubbleViewType;
    [bubbleView setupBubbleEffectWithItems:info];
    [hostViewController.view addSubview:bubbleView];
}

- (void)showNotificationsListFromViewController:(nonnull UIViewController *)hostViewController
                                   withDelegate:(id <MessagesViewControllerDelegate>)delegate
{
    [[NSNotificationCenter defaultCenter] removeObserver:hostViewController
                                                    name:@"getAllUserMessages"
                                                  object:nil];
    if (![[UserManager sharedInstance] isLoggedIn])
    {
        [[UserManager sharedInstance] showLoginFromViewController:hostViewController
                                                  eventLoadOrigin:nil
                                                    preLoginBlock:^{

                                                    }
                                                  completionBlock:^(BOOL success) {

                                                  }];
        return;
    }

    [[MessagesManager sharedInstance] hadReadMessages];
    MessagesViewController *messageController = [ControllersFactory instantiateViewControllerWithIdentifier:@"MessagesViewControllerID" inStoryboard:kNewProfileStoryboard];
    messageController.delegate = delegate;
    [messageController presentByParentViewController:hostViewController animated:YES completion:nil];
}

@end
