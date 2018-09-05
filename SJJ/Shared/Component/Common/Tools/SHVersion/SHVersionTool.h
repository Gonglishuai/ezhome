#import <Foundation/Foundation.h>

@interface SHVersionTool : NSObject

/**
 * 检测版本
 */
+ (void)requestForCheckVersion;

/**
 * 注册版本提醒的本地推送
 */
+ (void)registerLocalNotificationForVersionUpdate;

/**
 * 取消版本提醒的本地推送
 */
+ (void)cancelLocalNotificationForVersionUpdate;

/**
 * APP打下下载地址去浏览器或者App Store
 */
+ (void)openApplicationStoreWithUrl:(NSString *)url;

/**
 * 检查版本号是否和bundle的version一致
 */
+ (BOOL)checkVersionCode:(NSString *)versionCode;

/**
 打电话

 @param telphoneString 电话号码
 */
+ (void)appCallSomeOne:(NSString *)telphoneString;

@end
