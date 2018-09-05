//
//  MessagesViewController.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import <UIKit/UIKit.h>

//#import <GAITrackedViewController.h>

@protocol MessagesViewControllerDelegate <NSObject>

- (void)popoverViewDidDismiss;

@end

@interface MessagesViewController : UIViewController

@property (nonatomic, weak) id <MessagesViewControllerDelegate> delegate;

- (void)presentByParentViewController:(UIViewController*)parentViewController
                             animated:(BOOL)animated
                           completion:(void (^ __nullable)(void))completion;

@end
