//
//  ReachabilityManager.m
//  Homestyler
//
//  Created by Avihay Assouline on 9/3/14.
//
//

#import "ReachabilityManager.h"
#import "HSMacros.h"

@interface ReachabilityManager ()

@property (strong, nonatomic) Reachability *internetReachability;
    
@end

@implementation ReachabilityManager

static ReachabilityManager *sharedInstance = nil;

/////////////////////////////////////////////////////////////////////////

+ (ReachabilityManager*)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[ReachabilityManager alloc] init];
        sharedInstance.isConnentionAvailable = YES;
        [sharedInstance registerForReachability];
    });
    
    return sharedInstance;
}

/////////////////////////////////////////////////////////////////////////

- (void)registerForReachability
{
    // Check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reactToNetworkChanges:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    _internetReachability = [Reachability reachabilityForInternetConnection];
    [_internetReachability startNotifier];
    
    [self reactToNetworkChanges:nil];

}

/////////////////////////////////////////////////////////////////////////

- (void)reactToNetworkChanges:(NSNotification *)notice
{
    NetworkStatus remoteHostStatus = [_internetReachability currentReachabilityStatus];
    
    BOOL previousConnectionStatus = self.isConnentionAvailable;
    switch (remoteHostStatus)
    {
        case ReachableViaWiFi:
        {
            //wifi
            self.isConnentionAvailable = YES;
            self.connectionType = ReachableViaWiFi;
        }break;

        case ReachableViaWWAN:
        {
            //3G
            self.isConnentionAvailable = YES;
            self.connectionType = ReachableViaWWAN;
        } break;
            
        case NotReachable:
        {
            self.isConnentionAvailable = NO;
            self.connectionType = NotReachable;

        } break;
        
    }

    // Only dispatch a change event in case there was one (Avoid transitions between WiFi to WWAN)
    if (previousConnectionStatus != self.isConnentionAvailable){

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkStatusChanged" object:nil];
        });
    }
}

-(NSString *)currentNetworkState {
    NetworkStatus remoteHostStatus = [_internetReachability currentReachabilityStatus];
    
    if (remoteHostStatus == ReachableViaWiFi) {
        return @"Wi-Fi";
    }else if (remoteHostStatus == ReachableViaWWAN) {
        return @"WWAN";
    }else{
        return @"NotReach";
    }
}



@end
