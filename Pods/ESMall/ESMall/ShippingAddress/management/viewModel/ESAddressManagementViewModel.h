//
//  ESAddressManagementViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/28.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESAddress.h"
#import "ESAddrerssAPI.h"

@interface ESAddressManagementViewModel : NSObject

/**
 获取地址列表

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveAddressListWithSuccess: (void(^)(NSArray <ESAddress *> *addresses))success
                            andFailure: (void(^)(NSString *msg))failure;


/**
 获取Address对象

 @param array 数据源
 @param index 索引
 @return Address
 */
+ (ESAddress *)getAddressFromArray:(NSArray *)array withIndex:(NSInteger)index;

/**
 获取地址名字

 @param array 数据源
 @param index 索引
 @return 地址联系人名字
 */
+ (NSString *)getAddressNameFromArray:(NSArray *)array withIndex:(NSInteger)index;

/**
 获取地址联系电话

 @param array 数据源
 @param index 索引
 @return 联系电话
 */
+ (NSString *)getAddressPhoneFromArray:(NSArray *)array withIndex:(NSInteger)index;


/**
 获取地址详情

 @param array 数据源
 @param index 索引
 @return 地址详情
 */
+ (NSString *)getAddressDetailFromArray:(NSArray *)array withIndex:(NSInteger)index;

/**
 是否是默认地址

 @param array 数据源
 @param index 索引
 @return YES:默认地址
 */
+ (BOOL)isDefaultAddressFromArray:(NSArray *)array withIndex:(NSInteger)index;

/**
 设置默认地址

 @param array 数据源
 @param index 索引
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)setDefaultAddressFromArray:(NSArray *)array
                         withIndex:(NSInteger)index
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(void))failure;

/**
 删除地址

 @param array 数据源
 @param index 索引
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteAddressFromArray:(NSMutableArray *)array
                     withIndex:(NSInteger)index
                   withSuccess:(void(^)(BOOL shouldRefresh))success
                    andFailure:(void(^)(void))failure;
@end
