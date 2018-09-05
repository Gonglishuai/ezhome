//
//  ESProprietorDemandProject.h
//  Consumer
//
//  Created by 焦旭 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  消费者项目

#import <Foundation/Foundation.h>

@interface ESProprietorDemandProject : NSObject

@property (nonatomic, strong) NSString *provinceName;   // 省
@property (nonatomic, strong) NSString *cityName;       // 市
@property (nonatomic, strong) NSString *districtName;   // 区
@property (nonatomic, strong) NSString *communityName;  // 小区名称
@property (nonatomic, strong) NSString *contest;        // 活动标识
@property (nonatomic, strong) NSString *designAssetId;  // 项目id
@property (nonatomic, strong) NSString *projectNum;  // ???

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
