//
//  UMengServices.h
//  ESFoundation
//
//  Created by jiang on 2017/11/7.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDataAnalysisEvent.h"

@interface UMengServices : NSObject

/**友盟注册*/
+ (void)setupUMengServices;


/**
 事件打点统一调用调用方法
 @param eventId 事件
 */
+ (void)eventWithEventId:(NSString *)eventId;
+ (void)eventWithEventId:(NSString *)eventId label:(NSString *)label;
+ (void)eventWithEventId:(NSString *)eventId attributes:(NSDictionary *)parameters;

//登录退出
+ (void)eventLoginWithAccount:(NSString *)account;
+ (void)eventLogout;


/**页面打点*/
+ (void)beginLogPageViewWithPageName:(NSString *)pageName;
+ (void)endLogPageViewWithPageName:(NSString *)pageName;
    
@end
