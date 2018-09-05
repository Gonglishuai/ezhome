//
//  HSPopupViewControllerHelper.h
//  Homestyler
//
//  Created by Eric Dong on 05/10/18.
//

#import <UIKit/UIKit.h>

@interface HSPopupViewControllerHelper : NSObject

- (void)presentViewController:(nonnull UIViewController*)viewController
       byParentViewController:(nonnull UIViewController*)parentViewController
                maskViewBlock:(UIView *__nonnull(^__nonnull)(void))maskViewBlock
             contentViewBlock:(UIView *__nonnull(^__nonnull)(void))contentViewBlock
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion;

- (void)dismissViewController:(nonnull UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion;

@end
