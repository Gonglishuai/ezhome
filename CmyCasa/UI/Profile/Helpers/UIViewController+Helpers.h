//
//  UIViewController+Helpers.h
//  Homestyler
//
//  Created by Yiftach Ringel on 23/06/13.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helpers)

- (UIAlertView*)showErrorWithMessage:(NSString*)message;
- (UIAlertView*)showErrorWithMessageWithoutDelegate:(NSString*)message;
- (BOOL)isConnectionAvailable;
- (BOOL)isModal;
@end
