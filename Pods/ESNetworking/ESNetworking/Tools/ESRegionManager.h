//
//  ESRegionManager.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  行政区服务管理

#import <Foundation/Foundation.h>
#import "ESRegionModel.h"

@interface ESRegionManager : NSObject

+ (instancetype)sharedInstance;

/**
 获取行政区域信息
 */
+ (void)retrieveNewDistrict;

/**
 获取父级id为parentId的区域
 
 @param parentId 父级id
 @param success 成功回调
 */
+ (void)getRegionsWithParentId:(NSString *)parentId
                   withSuccess:(void(^)(NSArray <ESRegionModel *>*array))success;

/**
 获取城市的区域信息

 @param regionId 当前区域id
 @param success 成功回调
 */
+ (void)getRegionWithId:(NSString *)regionId
            withSuccess:(void(^)(ESRegionModel *region))success;

/**
 根据city code获取region id
 
 @param cityName 城市名称
 @param success 成功回调
 */
+ (void)getRegionWithCityName:(NSString *)cityName
                  withSuccess:(void(^)(ESRegionModel *region))success;

/**
 根据city name获取省市区信息
 
 @param cityName 高德城市名称
 @param success 成功回调
 */
+ (void)getRegionInfoWithCityName:(NSString *)cityName
                 withDistrictCode:(NSString *)districtCode
                      withSuccess:(void(^)(ESRegionModel *province, ESRegionModel *city, ESRegionModel *district))success;

@end
