


#import "SHPushNotificationHandler.h"

@implementation SHPushNotificationHandler

#pragma mark - Methods
// 删除iPhone通知中心收到的未阅读(点开)的推送消息
+ (void)removeMessagesAtNotificationCenter
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - Local Notification
+ (void)registerLocalNotificationWithData:(NSDate *)date
                                  message:(NSString *)message
                                 userInfo:(NSDictionary *)userInfo
{
    UILocalNotification *localNoti = [[UILocalNotification alloc] init];
    localNoti.alertBody = message;
    localNoti.fireDate = date;
    localNoti.soundName = UILocalNotificationDefaultSoundName;
    localNoti.userInfo = userInfo;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
}

+ (BOOL)cancelLocalNotificationUserInfo:(NSDictionary *)userInfo
{
    if (!userInfo || ![userInfo isKindOfClass:[NSDictionary class]])
        return NO;
    
    BOOL cancelSuccess = NO;
    NSArray * localNotis = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification * localNotification in localNotis)
    {
        if ([[localNotification.userInfo objectForKey:@"key"] isEqualToString:userInfo[@"key"]]) {
            //取消 本地推送
            [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
            cancelSuccess = YES;
        }
    }
    
    return cancelSuccess;
}

@end
