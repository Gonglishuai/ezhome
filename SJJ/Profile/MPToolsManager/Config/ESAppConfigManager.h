//
//  ESAppConfigManager.h
//  Mall
//
//  Created by 焦旭 on 2017/9/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  应用配置管理类

#import <Foundation/Foundation.h>
#import "ESAppConfig.h"
#import "ESAppConstantInfo.h"

@interface ESAppConfigManager : NSObject

@property (nonatomic, strong) ESAppConfig *appConfig;

@property (nonatomic, strong) NSArray *refreshTips;

+ (instancetype)sharedManager;

- (void)start;

@end
