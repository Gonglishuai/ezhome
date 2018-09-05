
#import "ESDeviceUtil.h"
#import "ESMessageAPI.h"
#import "JRKeychain.h"
#import "ESJPushManager.h"

#define PLATOR_CONSUMER_MBELONG_TYPE @"96"

@implementation ESDeviceUtil

+ (void)deleteDeviceCallback:(void (^) (void))cb
{
    NSString *uuid = [self getUUID];
    [ESMessageAPI deleteDeviceWithUUID:uuid
                               success:^(NSData *data)
    {
        SHLog(@"删除关联成功");
        if (cb)
        {
            cb();
        }
        
    } failure:^(NSError *error) {
        
        SHLog(@"删除关联失败");
        if (cb)
        {
            cb();
        }
    }];
}

+ (void)addDeviceAndLinked
{
    // 先删再加
    [self deleteDeviceCallback:^{

        // 获取极光registrationID
        [ESJPushManager registrationIDCompletionCallBack:^(NSString * _Nullable registrationID) {
            
            if (registrationID)
            {
                NSMutableDictionary *body = [[self getAddDeviceBody] mutableCopy];
                [body setObject:registrationID forKey:@"deviceId"];
                // 将极光registrationID与用户关联
                [ESMessageAPI addDeviceWithBody:[body copy]
                                        success:^(NSData *data)
                 {
                     
                     SHLog(@"添加设备成功");
                 } failure:^(NSError *error) {
                     
                     SHLog(@"添加设备失败:%@", error.localizedDescription);
                 }];
            }
        }];
    }];
}

+ (NSDictionary *)getAddDeviceBody
{
    NSString *uuid = [self getUUID];
    NSString *jMmeberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    if (!uuid
        || !jMmeberId)
    {
        return nil;
    }
    
    NSInteger deviceType = 2; // 1 安卓; 2 iOS
    NSDictionary *body = @{
                           @"memberId": jMmeberId,
                           @"uuid": uuid,
                           @"belongType": PLATOR_CONSUMER_MBELONG_TYPE,
                           @"deviceType": @(deviceType)
                           };
    return body;
}

+ (NSString *)getUUID
{
    NSString *uuid = [JRKeychain loadUUID];
    if (uuid
        && [uuid isKindOfClass:[NSString class]]
        && uuid.length > 0)
    {
        return uuid;
    }
    
    uuid = [self createUUID];
    
    // 保存到Keychain
    [JRKeychain saveUUIDString:uuid];
    
    return uuid;
}

+ (NSString *)createUUID
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    
    CFRelease(puuid);
    
    CFRelease(uuidString);
    
    return result;
}

@end
