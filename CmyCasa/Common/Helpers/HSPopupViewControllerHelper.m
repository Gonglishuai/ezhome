//
//  HSPopupViewControllerHelper.m
//  Homestyler
//
//  Created by Eric Dong on 05/10/18.
//

#import "HSPopupViewControllerHelper.h"


@interface HSPopupViewControllerHelper ()

@property (weak, nonatomic) UIView *maskBgView;
@property (weak, nonatomic) UIView *contentView;

@end

@implementation HSPopupViewControllerHelper

- (void)presentViewController:(nonnull UIViewController *)viewController
       byParentViewController:(nonnull UIViewController*)parentViewController
                maskViewBlock:(UIView *__nonnull(^__nonnull)(void))maskViewBlock
             contentViewBlock:(UIView *__nonnull(^__nonnull)(void))contentViewBlock
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion {
    [parentViewController.view addSubview:viewController.view];
    [parentViewController addChildViewController:viewController];

    if (!animated) {
        if (completion != nil) {
            completion();
        }
        return;
    }

    self.maskBgView = maskViewBlock();
    self.contentView = contentViewBlock();

    self.maskBgView.alpha = 0;
    self.contentView.alpha = 0;
    self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);

//    [UIView animateWithDuration:0.35 animations:^{
//        self.maskBgView.alpha = 0.5;
//        self.contentView.alpha = 1;
//    } completion:nil];

    [UIView animateWithDuration:0.35
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.maskBgView.alpha = 0.5;
                         self.contentView.alpha = 1;
                         self.contentView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

- (void)dismissViewController:(nonnull UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion {
    if (!animated) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
        if (completion != nil) {
            completion();
        }
        return;
    }

    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.maskBgView.alpha = 0;
                         self.contentView.alpha = 0;
                         self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                     } completion:^(BOOL finished) {
                         self.contentView.transform = CGAffineTransformIdentity;
                         self.maskBgView.alpha = 0;
                         self.contentView.alpha = 1;
                         [viewController.view removeFromSuperview];
                         [viewController removeFromParentViewController];
                         if (completion != nil) {
                             completion();
                         }
                     }];
}

@end
