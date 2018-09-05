
#import <Foundation/Foundation.h>
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface ESJPushManager : NSObject

/// 初始化JPush
+ (void)setupWithOption:(NSDictionary *_Nullable)launchingOption;

/*!
 * @abstract JPush标识此设备的 registrationID
 *
 * @discussion SDK注册成功后, 调用此接口获取到 registrationID 才能够获取到.
 *
 * JPush 支持根据 registrationID 来进行推送.
 * 如果你需要此功能, 应该通过此接口获取到 registrationID 后, 上报到你自己的服务器端, 并保存下来.
 * registrationIDCompletionHandler:是新增的获取registrationID的方法，需要在block中获取registrationID,resCode为返回码,模拟器调用此接口resCode返回1011,registrationID返回nil.
 * 更多的理解请参考 JPush 的文档网站.
 */
+ (void)registrationIDCompletionCallBack:(void (^_Nullable) (NSString * _Nullable registrationID))cb;

@end
