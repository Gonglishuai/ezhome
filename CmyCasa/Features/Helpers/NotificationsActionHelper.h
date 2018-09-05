//
//  NotificationsActionHelper.h
//  Homestyler
//
//  Created by liuyufei on 5/9/18.
//

#import <UIKit/UIKit.h>
#import "MessagesViewController.h"
#import "BubbleEffectView.h"

@interface NotificationsActionHelper : NSObject

- (void)showBubbleView:(BubbleViewType)bubbleViewType
        withSourceView:(nonnull UIView *)sourceView
 withNotificationsInfo:(nonnull NSArray *)info
    fromViewController:(nonnull UIViewController *)hostViewController;

- (void)showNotificationsListFromViewController:(nonnull UIViewController *)hostViewController
                                   withDelegate:(id <MessagesViewControllerDelegate>)delegate;

@end
