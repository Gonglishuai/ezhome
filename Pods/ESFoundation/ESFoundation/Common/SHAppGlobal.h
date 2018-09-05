//
//  AppController.h
//  MarketPlace
//
//  Created by zzz on 16/1/21.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ESLoginType)
{
    ESLoginTypeUnKnow = 0,
    ESLoginTypeHomePage,
    ESLoginTypeMasterialHome
};

@interface SHAppGlobal : NSObject
 
+(NSString*)AppGlobal_GetAppMainVersion;

+(BOOL) AppGlobal_GetIsDesignerMode;
+(BOOL) AppGlobal_GetIsConsumerMode;
+(BOOL) AppGlobal_GetIsInspectorMode;
+(BOOL) AppGlobal_GetIsClientmanagerMode;

/// clear cookie.
+ (void)clearCookie;

/// open privacy.
+ (void)openSettingPrivacy;

+ (BOOL)isHaveNetwork;
@end
