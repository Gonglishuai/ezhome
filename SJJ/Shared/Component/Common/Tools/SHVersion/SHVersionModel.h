//
//  SHVersionModel.h
//  Enterprise
//
//  Created by 牛洋洋 on 2017/4/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHLocalNotificationModel : NSObject

@property (nonatomic, assign) NSInteger time;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *download_url;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

@interface SHVersionModel : NSObject

// json 字段释义:
//   "platform":施工或者设计平台
//   "version_code": 服务器版本号,
//   "level": 更新级别，0-不提示，1-弹出更新弹窗可以关闭按钮，2-强更，弹窗不可关闭
//   "status": 是否关闭更新, ios上线审核期间，status必须为关闭状态，0-关闭，1-打开
//   "message": [],// 描述
//   "download_url" : 安卓下载apk的链接
//   "local_notifications" : [{time: 10, message: "描述", key: "local_notification_version_update"}] // 本地推送相关的信息

@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *version_code;
@property (nonatomic, copy) NSArray *message;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *download_url;
@property (nonatomic, copy) NSArray <SHLocalNotificationModel *> *local_notifications;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
