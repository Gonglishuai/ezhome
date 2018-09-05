

#import <Foundation/Foundation.h>

@interface SHPushNotificationHandler : NSObject

+ (void)registerLocalNotificationWithData:(NSDate *)date
                                  message:(NSString *)message
                                 userInfo:(NSDictionary *)userInfo;

+ (BOOL)cancelLocalNotificationUserInfo:(NSDictionary *)userInfo;

@end
