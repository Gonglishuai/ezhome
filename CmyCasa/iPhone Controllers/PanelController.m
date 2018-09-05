//
//  PanelController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/18/13.
//
//

#import "PanelController.h"
#import "SplashScreenController.h"
#import "MenuViewController_iPhone.h"
#import "SplashScreenViewController_iPhone.h"
#import "UIMenuManager.h"
#import "ControllersFactory.h"

#define MENU_SLIDE_X_POS 274
@interface PanelController ()
{
    UINavigationController * rootController;
}

@end

@implementation PanelController

-(UINavigationController*)getNavigation{
    return  rootController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIMenuManager sharedInstance] setIsMenuPresented:NO];
    [[UIMenuManager sharedInstance] setIsMenuOpenAllowed:YES];
    
    UISwipeGestureRecognizer* swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightFrom:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftFrom:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        
    
    SplashScreenViewController_iPhone * splash = (SplashScreenViewController_iPhone*)[ControllersFactory instantiateViewControllerWithIdentifier:@"SplashScreenID" inStoryboard:kMainStoryBoard];
    
    rootController = [[UINavigationController alloc] initWithRootViewController:splash];
    
    [rootController setNavigationBarHidden:YES];
    
//    MenuViewController_iPhone * menuController = (MenuViewController_iPhone*)[[UIMenuManager sharedInstance] galleryMenuViewController];
//
//    [self.view addSubview:menuController.view];
//    [self addChildViewController:menuController];

    [self.view addSubview:rootController.view];
    [self addChildViewController:rootController];
    
    [self.view addGestureRecognizer:swipeLeftGestureRecognizer];
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];
}

- (void)handleSwipeRightFrom:(UIGestureRecognizer*)recognizer {
    if ([[UIMenuManager sharedInstance] isMenuOpenAllowed] == NO) {
        return;
    }
    
    if ([[UIMenuManager sharedInstance] isMenuPresented] == NO) {
        
        if ([[rootController topViewController] respondsToSelector:@selector(openMenu:)]) {
            id<IphoneMenuManagerDelegate> deleg=(id<IphoneMenuManagerDelegate>)[rootController topViewController];
            
            [deleg openMenu:nil];
        }
    }
}

- (void)handleSwipeLeftFrom:(UIGestureRecognizer*)recognizer {
    if ([[UIMenuManager sharedInstance] isMenuOpenAllowed] == NO) {
        return;
    }
    
    if ([[UIMenuManager sharedInstance] isMenuPresented] ) {
        if ([[rootController topViewController] respondsToSelector:@selector(openMenu:)]) {
            id<IphoneMenuManagerDelegate> deleg=(id<IphoneMenuManagerDelegate>)[rootController topViewController];
            
            [deleg openMenu:nil];
        }
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)shouldAutorotate{
    return [[rootController topViewController] shouldAutorotate];
}

- (NSUInteger)supportedInterfaceOrientations {
    return [[rootController topViewController] supportedInterfaceOrientations];
}

@end






