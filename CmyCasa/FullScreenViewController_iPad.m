//
//  FullScreenViewController_iPad.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/15/13.
//
//

#import "UIImageView+ViewMasking.h"
#import "FullScreenViewController_iPad.h"
#import "ShoppingListViewController_iPad.h"
#import "UIView+Alignment.h"
#import "UILabel+Size.h"
#import "ProfIndexViewController.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"
#import "UILabel+NUI.h"
#import "ProgressPopupViewController.h"
#import "GalleryArticleBaseViewController.h"
#import "NSString+CommentsAndLikesNum.h"

#define UserLoginViewControllerTag 100

const unsigned int g_numOfDesiredItems = 300;
const unsigned int g_maxLayoutToShow = 5;

@interface FullScreenViewController_iPad ()

@property(nonatomic, weak) ShoppingListViewController_iPad* shoppingListVC;

@end

@implementation FullScreenViewController_iPad

-(void)dealloc{
    
    NSLog(@"dealloc - FullScreenViewController_iPad");
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (void)openProfessionalPageWithId:(NSString *)professionalId
{
    ProfPageViewController* profPageViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];
    [profPageViewController setProfId:professionalId];
    [self.navigationController pushViewController:profPageViewController animated:YES];
}

#pragma mark - GalleryImageDesignInfoCellDelegate

- (void)showFullDesignImage:(DesignBaseClass*)design {

}

- (void)showUserProfile:(DesignBaseClass *)design {
    if (design && ![design.uid isEqualToString:[ConfigManager getCompanyDesignerUid]]) {
        if ([self.currentItemDelegate respondsToSelector:@selector(isProfessional)]) {
            NSString * userID = @"";

            if ([self.currentItemDelegate isProfessional]) {
                userID = [self.currentItemDelegate getUserID];
                [self openProfessionalPageWithId:userID];
            } else {
                if (design.uid != nil) {
                    [[UIMenuManager sharedInstance] openProfilePageForsomeUser:design.uid];
                    userID = design.uid;
                }
            }

            [[UIMenuManager sharedInstance]updateMenuSelectionIndexAccordingToUserId:userID];
        }
    }
}

- (void)showShoppingList:(DesignBaseClass*)design {
    if (_shoppingListVC != nil)
        return;

    _shoppingListVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"iPadShoppingList" inStoryboard:kGalleryStoryboard];
    _shoppingListVC.designObj = design;

    //_shoppingListVC.view.transform = CGAffineTransformMakeScale(0.01, 0.01);

    [self addChildViewController:_shoppingListVC];
    [self.view addSubview:_shoppingListVC.view];

//    [UIView animateWithDuration:0.5
//                          delay:0.0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:0.3
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         _shoppingListVC.view.transform = CGAffineTransformIdentity;
//                     } completion:^(BOOL finished) {
//                         [_shoppingListVC startBgAnimation];
//                     }];
    [_shoppingListVC startBgAnimation];
}

@end
