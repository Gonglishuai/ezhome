//
//  MessagesViewController_iPhone.m
//  Homestyler
//
//  Created by liuyufei on 5/4/18.
//

#import "MessagesViewController_iPhone.h"
#import "DesignItemLikeActionHelper.h"
#import "GalleryItemBaseViewController.h"
#import "DesignItemShareActionHelper.h"

@interface MessagesViewController_iPhone ()

@property (nonatomic, strong) DesignItemLikeActionHelper *likeActionHelper;
@property (nonatomic, strong) DesignItemShareActionHelper *shareActionHelper;

@end

@implementation MessagesViewController_iPhone

- (void)presentByParentViewController:(UIViewController*)parentViewController
                             animated:(BOOL)animated
                           completion:(void (^ __nullable)(void))completion
{
    [parentViewController.navigationController pushViewController:self animated:animated];
    if (animated && completion != nil) {
        completion();
    }
}

#pragma mark - Action
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
