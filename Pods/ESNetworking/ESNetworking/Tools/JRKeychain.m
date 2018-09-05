//
//  JRKeychain.m
//  Consumer
//
//  Created by jiang on 2017/6/8.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRKeychain.h"

static NSString * const kUUIDKeyChainKey = @"JRUUIDKeyChainKey";
static NSString * const kUUID = @"JRUUID";

@implementation JRKeychain


/**
 *  存储单项用户信息字符串到 KeyChain
 *
 *  @param service NSString
 */
+ (void)saveSingleInfo:(NSString *)string infoCode:(UserInfoCode)infoCode {
    NSMutableDictionary *tempInfo = [NSMutableDictionary dictionaryWithDictionary:[JRKeychain loadAllUserInfo]];
    switch (infoCode) {
        case UserInfoCodeType: {//用户角色
            [tempInfo setObject:[[JRKeychain checkValue:string] lowercaseString] forKey:kUserInfoCodeType];
            break;
        }
        case UserInfoCodeJId: {//新用户id
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeJId];
            break;
        }
        case UserInfoCodeXToken: {//x_token
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeXToken];
            break;
        }

        case UserInfoCodePhone: {//mobile_number电话号码
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodePhone];
            break;
        }
        case UserInfoCodeName: {//nick_name昵称
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeName];
            break;
        }

        case UserInfoCodeUserName: {//userName昵称
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeUserName];
            break;
        }
            
        case UserInfoCodeUid: {//hs_uid
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeUid];
            break;
        }
        case UserInfoCodeAvatar: {//avatar头像
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeAvatar];
            break;
        }
        case UserInfoCodeLogState: {//登录状态
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeLogState];
            break;
        }
        case UserInfoCodeNIMToken: {
            [tempInfo setObject:[JRKeychain checkValue:string] forKey:kUserInfoCodeNIMToken];
            break;
        }
            
        default:
            break;
    }
    [JRKeychain save:kUserInfoKeyChainKey data:tempInfo];
}

/**
 *  存储全部用户信息到 KeyChain
 *
 *  @param service NSString
 */
+ (void)saveAllUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *tempInfo = [NSMutableDictionary dictionary];
    
    [tempInfo setObject:[[JRKeychain checkValue:userInfo[@"memberType"]] lowercaseString] forKey:kUserInfoCodeType];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"memberId"]] forKey:kUserInfoCodeJId];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"avatar"]] forKey:kUserInfoCodeAvatar];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"X-Token"]] forKey:kUserInfoCodeXToken];
    NSString *phone = [NSString stringWithFormat:@"%@",userInfo[@"account"]];
    [tempInfo setObject:[JRKeychain checkValue:phone] forKey:kUserInfoCodePhone];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"nickName"]] forKey:kUserInfoCodeName];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"userName"]] forKey:kUserInfoCodeUserName];
    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"uid"]] forKey:kUserInfoCodeUid];
    [tempInfo setObject:@"YES" forKey:kUserInfoCodeLogState];

    [tempInfo setObject:[JRKeychain checkValue:userInfo[@"nimToken"]] forKey:kUserInfoCodeNIMToken];
    
    [JRKeychain save:kUserInfoKeyChainKey data:tempInfo];
}

/**
 *  从 KeyChain 获取全部用户信息
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)loadAllUserInfo {
    NSDictionary *userInfo = (NSDictionary *)[JRKeychain load:kUserInfoKeyChainKey];
    return userInfo;
}

/**
 *  从 KeyChain 获取单项用户信息
 *
 *  @return NSString
 */
+ (NSString *)loadSingleUserInfo:(UserInfoCode)infoCode {
    NSDictionary *userInfo = (NSDictionary *)[JRKeychain load:kUserInfoKeyChainKey];
    switch (infoCode) {
        case UserInfoCodeType: {//用户角色
            return [userInfo objectForKey:kUserInfoCodeType] ? [userInfo objectForKey:kUserInfoCodeType] : @"";
            break;
        }
        case UserInfoCodeJId: {//用户id
            return [userInfo objectForKey:kUserInfoCodeJId] ? [userInfo objectForKey:kUserInfoCodeJId] : @"0";
            break;
        }
        case UserInfoCodeXToken: {//x_token
            return [userInfo objectForKey:kUserInfoCodeXToken] ? [userInfo objectForKey:kUserInfoCodeXToken] : @"";
            break;
        }
        case UserInfoCodePhone: {//mobile_number电话号码
            return [userInfo objectForKey:kUserInfoCodePhone] ? [userInfo objectForKey:kUserInfoCodePhone] : @"";
            break;
        }
        case UserInfoCodeName: {//nick_name昵称
            return [userInfo objectForKey:kUserInfoCodeName] ? [userInfo objectForKey:kUserInfoCodeName] : @"";
            break;
        }
        case UserInfoCodeUserName: {//userName昵称
            return [userInfo objectForKey:kUserInfoCodeUserName] ? [userInfo objectForKey:kUserInfoCodeUserName] : @"";
            break;
        }
        case UserInfoCodeUid: {//uid
            return [userInfo objectForKey:kUserInfoCodeUid] ? [userInfo objectForKey:kUserInfoCodeUid] : @"";
            break;
        }

        case UserInfoCodeAvatar: {//avatar头像
            return [userInfo objectForKey:kUserInfoCodeAvatar] ? [userInfo objectForKey:kUserInfoCodeAvatar] : @"";
            break;
        }
        case UserInfoCodeLogState: {//登录状态
            return [userInfo objectForKey:kUserInfoCodeLogState] ? [userInfo objectForKey:kUserInfoCodeLogState] : @"";
            break;
        }
        case UserInfoCodeNIMToken: {
            return [userInfo objectForKey:kUserInfoCodeNIMToken] ? [userInfo objectForKey:kUserInfoCodeNIMToken] : @"";
            break;
        }
            
        default:
            return @"";
            break;
    }
}


/**
 *  从 KeyChain 删除所有用户信息
 */
+ (void)deleteUserInfo {
    NSDictionary *userInfo = (NSDictionary *)[JRKeychain load:kUserInfoKeyChainKey];
    NSString *type = [userInfo objectForKey:kUserInfoCodeType] ? [userInfo objectForKey:kUserInfoCodeType] : @"";
    [JRKeychain delete:kUserInfoKeyChainKey];
    [JRKeychain saveSingleInfo:type infoCode:UserInfoCodeType];
}

/**
 存UUID
 
 @param uuidStr UUID
 */
+ (void)saveUUIDString:(NSString *)uuidStr {
    NSMutableDictionary *uuidInfo = [NSMutableDictionary dictionary];
    [uuidInfo setObject:[[JRKeychain checkValue:uuidStr] lowercaseString] forKey:kUUID];
    [JRKeychain save:kUUIDKeyChainKey data:uuidInfo];
}


/**
 获取UUID
 
 @return UUID
 */
+ (NSString *)loadUUID {
    NSDictionary *uuidInfo = (NSDictionary *)[JRKeychain load:kUUIDKeyChainKey];
    return [uuidInfo objectForKey:kUUID] ? [uuidInfo objectForKey:kUUID] : @"";
}



+ (NSString *)checkValue:(id)value {
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        long longValue = [value longValue];
        return [NSString stringWithFormat:@"%ld", longValue];
    }
    
    return @"";
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [JRKeychain getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [JRKeychain getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [JRKeychain getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}


@end
