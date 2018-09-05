//
//  BaseSplashScreenViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/9/13.
//
//

#import "SplashScreenBaseViewController.h"
#import "WallpapersManager.h"
#import "FloortilesManager.h"
//#import "GAI.h"
#import "AppDelegate.h"
#import "AppsFlyerTracker.h"
//#import <Analytics/SEGAnalytics.h>
#import "PackageManager.h"

@interface SplashScreenBaseViewController ()

@end

@implementation SplashScreenBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.screenName = GA_SPLASH_SCREEN;
    
    AppDelegate * deleg=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if( [deleg.window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * nav=(UINavigationController *)deleg.window.rootViewController;
        [nav setNavigationBarHidden:YES];
    }
    
    [ReachabilityManager sharedInstance];

    // case we do NOT have network and offline mode is off
    if (![ConfigManager isAnyNetworkAvailable] && ![ConfigManager isOfflineModeActive]) {
        [self showExitAlert];
        return;
    }
    
    //case we do NOT have network and offline mode is on
    if (![ConfigManager isAnyNetworkAvailable] && [ConfigManager isOfflineModeActive]) {
        
        //check if package exist if yes load it otherwise exit
        if ([[PackageManager sharedInstance] isOffLinePackageExist]) {
            [[PackageManager sharedInstance] loadPackageFromDeliveryPackage];
        }else{
            [self showExitAlert];
            return;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNetworkLbl:)
                                                 name:@"network_notification"
                                               object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Init config data
    [[ConfigManager sharedInstance] init3dParties];
    
    [self start];
    [self showApp];

    //[self initializeHomestylerOnSplashScreen];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)showExitAlert{
    [ConfigManager showMessageIfDisconnected];
}

- (void)initializeHomestylerOnSplashScreen
{
    if (![ConfigManager isAnyNetworkAvailable] || ![[ConfigManager sharedInstance] isConfigLoaded])
    {
        [self performSelector:@selector(initializeHomestylerOnSplashScreen) withObject:nil afterDelay:0.5];
        return;
    }
    
    // Init config data
    [[ConfigManager sharedInstance] init3dParties];
    
    [self start];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"failed_action_no_network_found_start", @"You seem to be offline. Please check your internet connection and retry.")]) {
        
        [self start];
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"update_version_required", @"")]) {
        
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]];
        exit(0);
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"update_version_available", @"")]) {
        switch (buttonIndex) {
            case 0:
            {
                [self start];
            }
                break;
            case 1:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[ConfigManager sharedInstance] versionStorelink]]];
                [self start];
                
            }
                break;
            default:
                [self start];
                break;
        }
    }
}

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager
{
    NSMutableString *description = [NSMutableString string];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *crashLogPath = [documentsDirectory stringByAppendingPathComponent:@"lastEvent.log"];
    
    NSData *logData = [[NSFileManager defaultManager] contentsAtPath:crashLogPath];
    if ([logData length] > 0) {
        NSString *result = [[NSString alloc] initWithBytes:[logData bytes]
                                                    length:[logData length]
                                                  encoding: NSUTF8StringEncoding];
        
        [description appendString:result];
    }
    
    return description;
}

-(void)start{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void){
        [ConfigManager sharedInstance];
        [[AppCore sharedInstance] Initialize];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showApp{
#ifdef USE_HOCKEYAPP
    dispatch_async(dispatch_get_main_queue(), ^{

        [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:[ConfigManager getHockeyAppIdKey]
                                                               delegate:self];
        [[BITHockeyManager sharedHockeyManager] startManager];
        [[BITHockeyManager sharedHockeyManager].crashManager setCrashManagerStatus: BITCrashManagerStatusAutoSend];
    });
#endif
    
#ifdef USE_APPSFLYER
    if ([[ConfigManager sharedInstance] useAppsflyerTracking]) {
        NSString * distinct =  [[[UserManager sharedInstance] currentUser] userID] ? [[[UserManager sharedInstance] currentUser] userID] : @"";
        [AppsFlyerTracker sharedTracker].customerUserID = distinct;
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = [[ConfigManager sharedInstance] appsflyerDevKey];
        [AppsFlyerTracker sharedTracker].appleAppID = [[ConfigManager sharedInstance] appsflyerappleAppId];
        [AppsFlyerTracker sharedTracker].currencyCode = @"USD";
        [AppsFlyerTracker sharedTracker].isHTTPS = YES;
        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    }
#endif
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"network_notification" object:nil];
}

-(void)updateNetworkLbl:(NSNotification *)notif{
    if (notif) {
        NSString * networkError = (NSString*)[notif object];
        [self performSelectorInBackground:@selector(updateLabel:) withObject:networkError];
    }
}

-(void)updateLabel:(NSString*)networkError{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.networkLabel setText:networkError];
    });
}


@end
