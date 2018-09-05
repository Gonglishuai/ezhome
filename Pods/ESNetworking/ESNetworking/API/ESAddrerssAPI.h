//
//  ESAddrerssAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMaterialBaseAPI.h"

@interface ESAddrerssAPI : ESMaterialBaseAPI

/**
 获取用户地址列表

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getAddressListWithSuccess:(void(^)(NSArray *array))success
                       andFailure:(void(^)(NSError *error))failure;

/**
 设置地址为默认地址

 @param addressId 地址ID
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)setDefaultAddressWithAddressID:(NSString *)addressId
                           withSuccess:(void(^)(void))success
                            andFailure:(void(^)(NSError *error))failure;

/**
 删除某地址

 @param addressId 地址ID
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteAddressWithAddressID:(NSString *)addressId
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(NSError *error))failure;


/**
 更新地址

 @param addressId 地址ID
 @param addressInfo 地址更新信息
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateAddressWithAddressID:(NSString *)addressId
                   withAddressInfo:(NSDictionary *)addressInfo
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(NSError *error))failure;

/**
 新建地址

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)createNewAddress:(NSDictionary *)addressInfo
             withSuccess:(void(^)(void))success
              andFailure:(void(^)(NSError *error))failure;

/**
 根据cityName获取详细位置信息
 
 @param cityName 城市名字
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getLocationDetailWithCityName:(NSString *)cityName Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure;

/**
 获取行政区信息

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveNewDistrictWithSuccess:(void(^)(NSDictionary *content, NSDictionary *responseHeader))success
                            andFailure:(void(^)(NSError *error))failure;

/**
 获取确认订单的默认地址

 @param regionId 当前城市id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getOrderDefaultAddressWithRegionId:(NSString *)regionId
                               withSuccess:(void(^)(NSDictionary *dict))success
                                andFailure:(void(^)(NSError *error))failure;
@end
