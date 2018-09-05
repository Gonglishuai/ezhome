#import "SHVersionTool.h"
#import "SHVersionView.h"
#import "SHPushNotificationHandler.h"
#import "SHFileUtility.h"
#import "SHVersionModel.h"
#import <SHHttpRequestManager.h>
#import <ESHTTPSessionManager.h>

#define iTunes_Url @"https://itunes.apple.com/cn/lookup?id=956730262"

#define AWS_Url_Version_Consumer @"https://download.homestyler.com/shejijia-consumer-app/ios/ios_version_consumer.json"
#define AWS_Url_Version_Url AWS_Url_Version_Consumer

#define VERSION_RECORD_INDORMATION @"APP_SETTING/LOCAL_VERSION_UPDATE_RECORD"
#define VERSION_RECORD_INDORMATION_NAME @"version_record.plist"

@interface SHVersionTool ()

@end

@implementation SHVersionTool

+ (void)requestForCheckVersion
{
    [self getVersionJsonAtAWSWithUrl:[AWS_Url_Version_Url stringByAppendingString:[NSString stringWithFormat:@"?date=%f",[NSDate date].timeIntervalSince1970]]
                                            succes:^(NSDictionary *dict)
    {
        SHVersionModel *model = [[SHVersionModel alloc] initWithDictionary:dict];
        [self checkAwsSettingData:model];
        
    } failure:^(NSError *error) {
        SHLog(@"获取aws版本信息失败:%@",error);
    }];
}

/**
 * 检查AWS的数据
 */
+ (void)checkAwsSettingData:(SHVersionModel *)model
{
    if (!model) return;
    
    // 如果status为0, 直接返回, 不进行任何操作.
    if (!model.status) return;
    
    // 判断弹窗等级
    if (model.level == 2)
    {
        SHLog(@"最高级, 无关闭按钮");
        [self checkVersionForUpdate:model
                           callBack:^(BOOL hasNewVersion,
                                      NSString *newVersion,
                                      NSString *downLoadUrl,
                                      NSArray *releaseNotes)
         {
             if (hasNewVersion)
             {
                 [self showVersionViewWithType:SHVersionViewTypeCompulsion
                                newVersionCode:newVersion
                                  releaseNotes:releaseNotes
                                   downloadUrl:downLoadUrl
                             notificationModel:[model.local_notifications firstObject]];
             }
         }];
    }
    else if (model.level == 1)
    {
        SHLog(@"中级, 有关闭按钮");
        [self checkVersionForUpdate:model
                           callBack:^(BOOL hasNewVersion,
                                      NSString *newVersion,
                                      NSString *downLoadUrl,
                                      NSArray *releaseNotes)
         {
             if (hasNewVersion)
             {
                 [self showVersionViewWithType:SHVersionViewTypeClose
                                newVersionCode:newVersion
                                  releaseNotes:releaseNotes
                                   downloadUrl:downLoadUrl
                             notificationModel:[model.local_notifications firstObject]];
             }
         }];
    }
    else
    {
        SHLog(@"不提示");
    }
}

/**
 * 检查是否有新版本
 */
+ (void)checkVersionForUpdate:(SHVersionModel *)model
                     callBack:(void(^)(BOOL hasNewVersion,
                                       NSString *newVersion,
                                       NSString *downLoadUrl,
                                       NSArray *releaseNotes))callBack
{
    [self checkVersionForUpdateConsumer:model.message
                               callback:callBack];
}

/**
 * 检查是否有新版本 -- 设计家服务端(施工)
 */
+ (void)checkVersionForUpdateEnterprise:(SHVersionModel *)model
                               callback:(void(^)(BOOL hasNewVersion,
                                                 NSString *newVersion,
                                                 NSString *downLoadUrl,
                                                 NSArray *releaseNotes))callBack
{
    BOOL hasNewVersion = [self checkVersionCode:model.version_code];
    BOOL couldShowWithVersionCode = [self checkVersionInformationWithKey:model.version_code];
    BOOL couldShowWithDateStr = [self checkDateInformation];

    if (hasNewVersion && couldShowWithVersionCode && couldShowWithDateStr)
    {
        if (callBack) callBack(YES, model.version_code, model.download_url, model.message);
    }
    else
    {
        if (callBack) callBack(NO, nil, nil, nil);
    }

}

/**
 * 检查是否有新版本 -- 设计家
 */
+ (void)checkVersionForUpdateConsumer:(NSArray *)messages
                             callback:(void(^)(BOOL hasNewVersion,
                                               NSString *newVersion,
                                               NSString *downLoadUrl,
                                               NSArray *releaseNotes))callBack
{
    [self requestForAppInformationAtiTunes:^(BOOL successStatus,
                                             NSString *versionCode,
                                             NSString *downLoadUrl,
                                             NSArray *releaseNotes)
     {
         if (successStatus)
         {
             BOOL hasNewVersion = [self checkVersionCode:versionCode];
             BOOL couldShow = [self checkVersionInformationWithKey:versionCode];
             if (hasNewVersion && couldShow)
             {
                 if (callBack) callBack(YES, versionCode, downLoadUrl, messages);
             }
             else
                 if (callBack) callBack(NO, nil, nil, nil);
         }
         else
             if (callBack) callBack(NO, nil, nil, nil);
     }];
}

/**
 * 检查版本号是否和bundle的version一致
 */
+ (BOOL)checkVersionCode:(NSString *)versionCode
{
    NSString *appVersion = versionCode;
    if (!appVersion || ![appVersion isKindOfClass:[NSString class]])
        return NO;
    
    NSString *localVersionId = [self getCurrentVersionCode];
    if ([localVersionId isEqualToString:appVersion])
        return NO;
    
    NSArray *versionBundle = [localVersionId componentsSeparatedByString:@"."];
    NSArray *versionAws = [appVersion componentsSeparatedByString:@"."];
    
    NSInteger minCount = versionBundle.count;
    if (versionAws.count < minCount) minCount = versionAws.count;
    
    for (NSInteger i = 0; i < minCount; i++)
    {
        NSInteger bundleVersionNum = [versionBundle[i] integerValue];
        NSInteger awsVersionNum = [versionAws[i] integerValue];
        if (awsVersionNum > bundleVersionNum)
        {
            return YES;
        }
        else if (awsVersionNum < bundleVersionNum)
        {
            return NO;
        }
    }
    
    if (versionAws.count > minCount)
        return YES;
    
    return NO;
}

/**
 * APP打开连接, 去浏览器或者App Store
 */
+ (void)openApplicationStoreWithUrl:(NSString *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

+ (void)appCallSomeOne:(NSString *)telphoneString {
    if (telphoneString == nil || telphoneString.length < 6) {
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",telphoneString]];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}


/**
 * 设计家去AppStore请求版本信息, 获取版本号, 下载地址, 更新文案等
 */
+ (void)requestForAppInformationAtiTunes:(void(^)(BOOL successStatus,
                                                  NSString *versionCode,
                                                  NSString *downLoadUrl,
                                                  NSArray *releaseNotes))callBack

{
    SHLog(@"请求iTunes中APP的信息");
    [self getAppInformationAtiTunes:iTunes_Url succes:^(NSDictionary *dict) {
        
        SHLog(@"请求成功:%@",dict);
        if (dict && [dict isKindOfClass:[NSDictionary class]])
        {
            if (dict[@"results"] && [dict[@"results"] isKindOfClass:[NSArray class]])
            {
                NSDictionary *dic = [dict[@"results"] firstObject];
                if (dic && [dic isKindOfClass:[NSDictionary class]])
                {
                    NSString *version = dic[@"version"];
                    NSString *downloadUrl = dic[@"trackViewUrl"];
                    NSString *releaseNotes = dic[@"releaseNotes"];
                    if (version
                        && [version isKindOfClass:[NSString class]]
                        && version.length != 0
                        && downloadUrl
                        && [downloadUrl isKindOfClass:[NSString class]]
                        && downloadUrl.length != 0
                        && releaseNotes
                        && [releaseNotes isKindOfClass:[NSString class]]
                        && releaseNotes.length != 0)
                        if (callBack)
                            callBack(YES, version, downloadUrl, [releaseNotes componentsSeparatedByString:@"\n"]);
                }
            }
        }
        else
        {
            if (callBack)
                callBack(NO, nil, nil, nil);
        }
    } failure:^(NSError *error) {
        
        SHLog(@"从iTunes获取App信息失败");
        if (callBack)
            callBack(NO, nil, nil, nil);
    }];
}

/**
 * 展示版本更新的视图
 */
+ (void)showVersionViewWithType:(SHVersionViewType)type
                 newVersionCode:(NSString *)newVersionCode
                   releaseNotes:(NSArray *)releaseNotes
                    downloadUrl:(NSString *)downLoadUrl
              notificationModel:(SHLocalNotificationModel *)model
{
    [SHVersionView showVersionViewWithType:type
                              releaseNotes:releaseNotes
                               downloadUrl:downLoadUrl
                                  callback:^(BOOL isClose, NSString *downloadUrl)
     {
         if (!isClose)
         {
             [self openApplicationStoreWithUrl:downLoadUrl];
         }
         
         // 如果是强制更新, 不做记录
         if (type == SHVersionViewTypeCompulsion) return ;
        
         // 写入本地, 当前版本内不再提示
         [self saveVersionCode:newVersionCode
              isCurrentVersion:NO];
         
         if(isClose && type == SHVersionViewTypeClose)
         {
             model.download_url = downLoadUrl;
             [self saveLocalNotification:model];
             [self updateLocalNotificationStatus:YES];
         }
     }];
}

#pragma mark - Local Notification
/**
 * 注册本地通知
 */
+ (void)registerLocalNotificationForVersionUpdate
{
    BOOL couldNotification = [self checkLocalNotificationStatus];
    if (!couldNotification) return;
    
    SHLocalNotificationModel *model = [self getLocalNotificationINfoAtVersionInformation];
    if (!model) return;
    
    SHLog(@"注册本地通知");
    [SHPushNotificationHandler
     registerLocalNotificationWithData:[NSDate dateWithTimeIntervalSinceNow:model.time]
     message:model.message
     userInfo:@{
                @"key"          : model.key,
                @"download_url" : model.download_url,
                }];
}

/**
 * 取消本地通知
 */
+ (void)cancelLocalNotificationForVersionUpdate
{
    // userinfo key 对应的value需要与上方注册的userinfo 中的一致
    BOOL cancelSuccess = [SHPushNotificationHandler cancelLocalNotificationUserInfo:@{@"key" : @"local_notification_version_update"}];
    [self updateLocalNotificationStatus:cancelSuccess];
    
    if (cancelSuccess)
        SHLog(@"取消本地推送成功");
    else
        SHLog(@"取消本地推送失败, 本地推送可能已执行或者暂未注册");
}

#pragma mark - Local Record Plist
/**
 * 保存版本号
 */
+ (void)saveVersionCode:(NSString *)versionCode
       isCurrentVersion:(BOOL)isCurrentVersion
{
    if (!versionCode
        || ![versionCode isKindOfClass:[NSString class]]
        || versionCode.length == 0)
        return ;
    
    NSMutableDictionary *localDict = [[self getVersionRecordInformation] mutableCopy];
    if (isCurrentVersion)
        [localDict setObject:versionCode forKey:@"current_version"];

    else
        [localDict setObject:versionCode forKey:versionCode];
    
    [self saveVersionCode:[localDict copy]];
}

/**
 * 保存日期
 */
+ (void)saveDateStr
{
    NSString *dateStr = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                       dateStyle:NSDateFormatterShortStyle
                                                       timeStyle:NSDateFormatterNoStyle];
    if (!dateStr
        || ![dateStr isKindOfClass:[NSString class]]
        || dateStr.length == 0)
    {
        return ;
    }
    
    NSMutableDictionary *localDict = [[self getVersionRecordInformation] mutableCopy];
    [localDict setObject:dateStr forKey:dateStr];
    
    [self saveVersionCode:[localDict copy]];
}

/**
 * 获取当前版本号, 如果用户更新了版本
 */
+ (NSString *)getCurrentVersionCode
{
    NSString *bundleVersionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *localVersionCode = [self getLocalCurrentVersionCode];
    if (![localVersionCode isEqualToString:bundleVersionCode])
        [self resetVersionInformation];
        
    return bundleVersionCode;
}

/**
 * 获取当前本地文件保存的版本号
 */
+ (NSString *)getLocalCurrentVersionCode
{
    NSDictionary *localDict = [self getVersionRecordInformation];
    NSString *current_version = localDict[@"current_version"];
    if (current_version
        && [current_version isKindOfClass:[NSString class]]
        && current_version.length > 0)
    {
        return current_version;
    }
    
    return @"";
}

/**
 * 检查本地保存的版本更新文件中是否有某个值, 有的话返回NO, 没得话YES
 */
+ (BOOL)checkVersionInformationWithKey:(NSString *)key
{
    if (!key
        || ![key isKindOfClass:[NSString class]]
        || key.length == 0)
        return NO;
    
    NSDictionary *localDict = [self getVersionRecordInformation];
    NSString *versionCodeValue = localDict[key];
    if (!versionCodeValue)
    {
        return YES;
    }
    
    return NO;
}

/**
 * 检查本地保存的时间串
 */
+ (BOOL)checkDateInformation
{
    NSString *dateStr = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                       dateStyle:NSDateFormatterShortStyle
                                                       timeStyle:NSDateFormatterNoStyle];
    NSDictionary *localDict = [self getVersionRecordInformation];
    NSString *dateValue = localDict[dateStr];
    if (!dateValue)
    {
        return YES;
    }
    
    return NO;
}

/**
 * 获取当前本地保存的版本更新文件中的记录
 */
+ (NSDictionary *)getVersionRecordInformation
{
    NSString *path = [[SHFileUtility getDocumentDirectory] stringByAppendingPathComponent:VERSION_RECORD_INDORMATION];
    NSString *localFilePath = [path stringByAppendingPathComponent:VERSION_RECORD_INDORMATION_NAME];
    
    NSDictionary *dict = @{@"current_version" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]};
    if (![SHFileUtility isFileExist:localFilePath])
    {
        [self saveVersionCode:dict];
        return dict;
    }
    
    NSDictionary *localDict = [NSDictionary dictionaryWithContentsOfFile:localFilePath];
    if ([localDict isKindOfClass:[NSDictionary class]])
        return localDict;
    
    return dict;
}

/**
 * 保存文件
 */
+ (void)saveVersionCode:(NSDictionary *)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]])
        return;
    
    NSString *path = [SHFileUtility createFolderInDocDir:VERSION_RECORD_INDORMATION];
    NSString *localFilePath = [path stringByAppendingPathComponent:VERSION_RECORD_INDORMATION_NAME];
    BOOL status = [dict writeToFile:localFilePath atomically:YES];
    if (status)
    {
        SHLog(@"写入成功");
    }
    else
    {
        SHLog(@"写入失败");
    }
}

/**
 * 重置本地版本更新的文件
 */
+ (void)resetVersionInformation
{
    NSDictionary *dict = @{@"current_version" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]};
    [self saveVersionCode:dict];
}

/**
 * 检查本地推送的状态, 即是否可注册本地推送, Yes可注册, NO不可注册
 */
+ (BOOL)checkLocalNotificationStatus
{
    return ![self checkVersionInformationWithKey:@"local_notification"];
}

/**
 * 保存本地推送的状态
 */
+ (void)updateLocalNotificationStatus:(BOOL)isSave
{
    NSMutableDictionary *localDict = [[self getVersionRecordInformation] mutableCopy];
    
    BOOL hsaLocalNotification = [self checkLocalNotificationStatus];
    if (isSave == hsaLocalNotification)
        return;
    
    if (isSave)
    {
        [localDict setObject:@"local_notification" forKey:@"local_notification"];
    }
    else
        [localDict removeObjectForKey:@"local_notification"];
    
    [self saveVersionCode:[localDict copy]];
}

+ (void)saveLocalNotification:(SHLocalNotificationModel *)model
{
    if (!model) return;
    
    NSInteger time         = model.time;
    NSString *message      = model.message;
    NSString *key          = model.key;
    NSString *download_url = model.download_url;
    if (!message
        || ![message isKindOfClass:[NSString class]]
        || !key
        || ![key isKindOfClass:[NSString class]]
        || !download_url
        || ![download_url isKindOfClass:[NSString class]]
        ) return;
    
    NSDictionary *notiDict = @{
                               @"key"          : key,
                               @"time"         : @(time),
                               @"message"      : message,
                               @"download_url" : download_url
                               };
    NSMutableDictionary *dict = [[self getVersionRecordInformation] mutableCopy];
    [dict setObject:notiDict forKey:key];
    [self saveVersionCode:[dict copy]];
}

/**
 * 从记录文件中获取app的本地推送设置
 */
+ (SHLocalNotificationModel *)getLocalNotificationINfoAtVersionInformation
{
    NSDictionary *localDict = [self getVersionRecordInformation];
    NSDictionary *notiDict = localDict[@"local_notification_version_update"];    
    SHLocalNotificationModel *notiModel = [[SHLocalNotificationModel alloc] initWithDictionary:notiDict];
    return notiModel;
}


/**
 * 获取AWS上的version json
 */
+ (void)getVersionJsonAtAWSWithUrl:(NSString *)url
                            succes:(void(^)(NSDictionary * dict))succes
                           failure:(void(^)(NSError *error))failure
{
    [SHHttpRequestManager Get:url
               withParameters:nil
                   withHeader:nil
                     withBody:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
     {
         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
         
         if (succes) {
             succes(dict);
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
         if (failure) {
             
             SHLog(@"%ld",(long)((NSHTTPURLResponse *)task.response).statusCode);
             failure(error);
         }
     }];
}

/**
 * 获取iTunes上APP的信息
 */
+ (void)getAppInformationAtiTunes:(NSString *)url
                           succes:(void(^)(NSDictionary * dict))succes
                          failure:(void(^)(NSError *error))failure
{
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:nil
                      withBody:nil
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask *task, NSData *responseData)
     {
         NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
         
         if (succes) {
             succes(dict);
         }
     } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
         if (failure) {
             
             failure(error);
         }
     }];
}
@end
