//
//  JRKeychain.h
//  Consumer
//
//  Created by jiang on 2017/6/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserInfoCode)//存储用户信息
{
    UserInfoCodeDefault = 0,//无意义
    UserInfoCodeType,//用户角色
    UserInfoCodeJId,//用户id
    UserInfoCodeXToken,//x_token
    UserInfoCodePhone,//acount手机电话号码
    UserInfoCodeName,//nickName昵称
    UserInfoCodeUserName,//userName昵称
    UserInfoCodeUid,//uid
    UserInfoCodeAvatar,//avatar头像
    UserInfoCodeLogState,//登录状态
    UserInfoCodeNIMToken,//云信token
    UserInfoCodeUUID,
};

static NSString * const kUserInfoKeyChainKey = @"JRUserInfoKeyChainKey";


static NSString * const kUserInfoCodeType = @"JRUserInfoCodeType";
static NSString * const kUserInfoCodeJId = @"JRUserInfoCodeJId";
static NSString * const kUserInfoCodeXToken = @"JRUserInfoCodeXToken";
static NSString * const kUserInfoCodePhone = @"JRUserInfoCodePhone";
static NSString * const kUserInfoCodeName = @"JRUserInfoCodeName";
static NSString * const kUserInfoCodeUserName = @"JRUserInfoCodeUserName";
static NSString * const kUserInfoCodeUid = @"JRUserInfoCodeUid";
static NSString * const kUserInfoCodeAvatar = @"JRUserInfoCodeAvatar";
static NSString * const kUserInfoCodeLogState = @"JRUserInfoCodeLogState";
static NSString * const kUserInfoCodeNIMToken = @"JRUserInfoCodeNIMToken";

static NSString * const kDeviceInfoCodeUUID = @"JRDeviceInfoCodeUUID";

@interface JRKeychain : NSObject

/**
 存储单项用户信息字符串到 KeyChain

 @param string 存储的内容
 @param infoCode 存储的信息key
 */
+ (void)saveSingleInfo:(NSString *)string infoCode:(UserInfoCode)infoCode;

/**
 存储全部用户信息到 KeyChain

 @param userInfo 用户信息
 */
+ (void)saveAllUserInfo:(NSDictionary *)userInfo;

/**
 *  从 KeyChain 获取全部用户信息
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)loadAllUserInfo;

/**
 *  从 KeyChain 获取单项用户信息
 *
 *  @return NSString
 */
+ (NSString *)loadSingleUserInfo:(UserInfoCode)infoCode;


/**
 *  从 KeyChain 删除所有用户信息
 */
+ (void)deleteUserInfo;


/**
 存UUID

 @param uuidStr UUID
 */
+ (void)saveUUIDString:(NSString *)uuidStr;


/**
 获取UUID

 @return UUID
 */
+ (NSString *)loadUUID;
@end
