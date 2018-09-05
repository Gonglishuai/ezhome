//
//  FullScreenViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "FullScreenViewController_iPhone.h"
#import "GalleryImageViewController_iPhone.h"
#import "LandscapeDesignViewController_iPhone.h"
#import "MyDesignEditViewController_iPhone.h"
#import "ProfessionalPageViewController_iPhone.h"
#import "ProfessionalsResponse.h"
#import "ShoppingListViewController_iPhone.h"

#import "UIManager.h"
#import "ControllersFactory.h"
#import "ProtocolsDef.h"

#import "MainViewController.h"


@interface FullScreenViewController_iPhone ()

@end

@implementation FullScreenViewController_iPhone
{
    CGPoint _lastContentOffsetForIphoneXSafeArea;
}

// iPhoneX 编辑设计时切换横竖屏会触发SafeArea并改变scrollview的contentOffset
-(void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if ([ConfigManager deviceTypeisIPhoneX]) {
        _lastContentOffsetForIphoneXSafeArea = self.scrollView.contentOffset;
    }
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        if ([ConfigManager deviceTypeisIPhoneX] && (self.scrollView.safeAreaInsets.left != 0 || self.scrollView.safeAreaInsets.right != 0)) {
            self.scrollView.contentOffset = _lastContentOffsetForIphoneXSafeArea;
        }
    }
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    NSLog(@"dealloc - FullScreenViewController_iPhone");
}

#pragma mark -----------------------------------------------------

- (void)scrollViewDidScroll:(UIScrollView *)in_scrollView {
    if ([[UIManager sharedInstance] pushDelegate].navigationController.topViewController != self ||
        [[[UIManager sharedInstance] pushDelegate].navigationController.presentedViewController isKindOfClass:[MainViewController class]]) {
        return;
    }
    [super scrollViewDidScroll:in_scrollView];
}

-(NSInteger)getScreenWidth{
    // WORDAROUND: use screen width since the view size is not determined when this is called with viewDidLoad
    return [UIScreen mainScreen].bounds.size.width;//self.view.frame.size.width;
}

-(int)getScreenHeight{
    return self.view.frame.size.height;
}

- (UIImage*) getScreenShot{

    if (self.currentItemDelegate) {
        return [self.currentItemDelegate getCurrentPresentingImage];
    }

    return nil;
}


#pragma mark - HSSharingViewControllerDelegate
- (void)didCancelSharingViewController {
    [self.backButton setEnabled:YES];
}

- (void)didFinishSharingViewController {
    [self.backButton setEnabled:YES];
}


#pragma mark - GalleryImageDesignInfoCellDelegate

- (void)showFullDesignImage:(DesignBaseClass *)design {
    if (self.presentedViewController)
        return;

    NSString * designId = design._id;
    if (![designId isEqualToString:self.currentItemDelegate.itemDetail._id])
        return;

    //load the landscape view
    LandscapeDesignViewController_iPhone * ldVc = [ControllersFactory instantiateViewControllerWithIdentifier:@"LandscapeDesignViewController" inStoryboard:kRedesignStoryboard];
    ldVc.delegate = self;
    [ldVc setItems:self.itemIdsArray];
    [ldVc setIndex:self.selectedItemIndex];

    [self presentViewController:ldVc animated:YES completion:nil];
}

- (void)showUserProfile:(DesignBaseClass *)design {

    if (design.isPro) {
        ProfessionalPageViewController_iPhone * ipv=[ControllersFactory instantiateViewControllerWithIdentifier:@"ProfPageViewController" inStoryboard:kProfessionalsStoryboard];

        NSString* profId =  design.uid;
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];

        [[[AppCore sharedInstance] getProfsManager]getProffesionalByID:profId completionBlock:^(id serverResponse, id error) {

            if (error) {

            } else {
                ProfessionalsResponse * profData=(ProfessionalsResponse*)serverResponse;


                ipv.professional=profData.currentProfessional;

                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:profId];
                                   [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                                   //_profButton.enabled=YES;
                                   [self.navigationController pushViewController:ipv animated:YES];
                               });
            }

            [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        } queue:dispatch_get_main_queue()];
    } else {
        if(design.uid && ![design.uid isEqualToString:[ConfigManager getCompanyDesignerUid]]) {
            [[UIMenuManager sharedInstance] openProfilePageForsomeUser:design.uid];
            [[UIMenuManager sharedInstance] updateMenuSelectionIndexAccordingToUserId:design.uid];
        }
    }
}

- (void)showShoppingList:(DesignBaseClass*)design {
    ShoppingListViewController_iPhone* shoppingListViewController = [ControllersFactory instantiateViewControllerWithIdentifier:@"iPhoneShoppingList" inStoryboard:kGalleryStoryboard];
    shoppingListViewController.designObj = design;

    [self.navigationController presentViewController:shoppingListViewController animated:YES completion:nil];
}


#pragma mark - LandscapeDesignViewControllerDelegate_iPhone
- (void)landscapeViewWillDismiss {
    if (self.presentedViewController == nil)
        return;

    if (![self.presentedViewController isKindOfClass:[LandscapeDesignViewController_iPhone class]])
        return;

    LandscapeDesignViewController_iPhone * ldVc = (LandscapeDesignViewController_iPhone*)self.presentedViewController;
    BOOL needUpdateLayout = self.selectedItemIndex != ldVc.index;
    self.selectedItemIndex = ldVc.index;
    [ldVc clearScrollView];
    [self dismissViewControllerAnimated:NO completion:^{
        if (needUpdateLayout) {
            [self tileLayout:YES];
        }
    }];
}

@end

