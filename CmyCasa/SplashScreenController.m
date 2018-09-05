//
//  SplashScreenController.m
//  CmyCasa
//
//  Created by Berenson Sergei on 1/28/13.
//
//

#import "SplashScreenController.h"
#import "ControllersFactory.h"
#import "GalleryBaseViewController.h"

@interface SplashScreenController () <HSSplashScreen, UIGestureRecognizerDelegate>

@end

@implementation SplashScreenController

- (void)showApp
{
    [super showApp];
    AppDelegate * deleg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [deleg startLoadingProcess];
    [[ConfigManager sharedInstance] cleanStreamsDirectory];

    GalleryBaseViewController* bsVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryBaseViewControllerID" inStoryboard:kGalleryStoryboard];
    bsVC.delegate = deleg;
    if( [deleg.window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * nav = (UINavigationController *)deleg.window.rootViewController;
        nav.interactivePopGestureRecognizer.delegate = (id)self;
        nav.interactivePopGestureRecognizer.enabled = YES;
        [nav setNavigationBarHidden:NO];
        [nav setViewControllers:[NSArray arrayWithObject:bsVC]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - SplashScreenController");
}

@end
