//
//  ESFoundationURLServices.m
//  ESFoundation
//
//  Created by jiang on 2017/11/13.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "ESFoundationURLServices.h"
#import "DefaultSetting.h"
#import "UMengServices.h"
#import "ESLoginManager.h"

@implementation ESFoundationURLServices

+ (void)registerESFoundationURLServices {
    /**---------------------------子组件的URLServices注册--------------------------**/
    
    //打点
    [MGJRouter registerURLPattern:@"/ESFoundation/Analysis" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------打点---------\n%@\n-------------------", routerParameters);
        NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:routerParameters[MGJRouterParameterUserInfo]] ;
        NSString *event = info[@"event"]?info[@"event"]:@"";
        [info removeObjectForKey:@"event"];
        [UMengServices eventWithEventId:event attributes:info];

    }];
    
    //退出登录
    [MGJRouter registerURLPattern:@"/ESFoundation/Logout" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------退出登录---------\n%@\n-------------------", routerParameters);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SJJ_LOGOUT" object:nil];
        [[ESLoginManager sharedManager] logout];
    }];
}

@end
