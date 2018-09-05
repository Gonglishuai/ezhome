//
//  iphoneSplashScreenViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/10/13.
//
//

#import "SplashScreenViewController_iPhone.h"
#import "ControllersFactory.h"
#import "GalleryBaseViewController.h"

@interface SplashScreenViewController_iPhone () <HSSplashScreen>

@end

@implementation SplashScreenViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     
    if (IS_PHONEPOD5()) {
        [self.backgroundImage setImage:[UIImage imageNamed:@"Default-568h"]];
    }
}

- (void)showApp
{
    [super showApp];
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate startLoadingProcess];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ConfigManager sharedInstance] cleanStreamsDirectory];
    });
    
    GalleryBaseViewController* bsVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryBaseViewControllerID" inStoryboard:kGalleryStoryboard];
    bsVC.delegate = delegate;
    
    if( [delegate.window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * nav = (UINavigationController *)delegate.window.rootViewController;
        nav.interactivePopGestureRecognizer.delegate = (id)self;
        nav.interactivePopGestureRecognizer.enabled = YES;
        [nav setNavigationBarHidden:NO];
        [nav setViewControllers:[NSArray arrayWithObject:bsVC]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - SplashScreenViewController_iPhone");
}

@end
