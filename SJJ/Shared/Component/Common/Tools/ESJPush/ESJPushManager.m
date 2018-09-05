
#import "ESJPushManager.h"

static NSString *channel = @"JPush";
#if DEBUG
static NSString *jpushKey = @"093f85de96fd0a35e55b90a4";
static BOOL isProduction = FALSE;
#else
static NSString *jpushKey = @"cb84089929552ec182050840";
static BOOL isProduction = TRUE;
#endif

@implementation ESJPushManager

+ (void)setupWithOption:(NSDictionary *_Nullable)launchingOption
{
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity
                                             delegate:nil];
    [JPUSHService setupWithOption:launchingOption
                           appKey:jpushKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
}

+ (void)registrationIDCompletionCallBack:(void (^) (NSString *registrationID))cb
{
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID)
    {
        if(resCode == 0)
        {
            SHLog(@"registrationID获取成功：%@",registrationID);
            if (cb)
            {
                cb(registrationID);
            }
        }
        else
        {
            SHLog(@"registrationID获取失败，code：%d",resCode);
            if (cb)
            {
                cb(nil);
            }
        }
    }];
}

@end
