//
//  ESSelectAddrViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  选择地址的view model 处理页面数据

#import <Foundation/Foundation.h>
#import "ESAddress.h"
#import "ESAddrerssAPI.h"

@interface ESSelectAddresses : NSObject
@property (nonatomic, assign) BOOL valid;
@property (nonatomic, strong) NSMutableArray <ESAddress *> *address;
@end

@interface ESSelectAddrViewModel : NSObject

/**
 获取地址列表

 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveAddressListWithSuccess: (void(^)(NSArray <ESSelectAddresses *> *addressArray))success
                            andFailure: (void(^)(NSString *msg))failure;

/**
 该组地址是否可用

 @param section 组索引
 @return YES:组内地址可用
 */
+ (BOOL)getAddressValidFromArray:(NSArray *)array withSection:(NSInteger)section;

/**
 获取组内地址个数

 @param array 数据源
 @param section 组索引
 @return 地址数量
 */
+ (NSInteger)getAddressNumsFromArray:(NSArray *)array
                         withSection:(NSInteger)section;

/**
 获取选择的地址

 @param array 数据源
 @param index 索引
 @return 地址
 */
+ (ESAddress *)getSelectedAddrFromArray:(NSArray *)array
                            withSection:(NSInteger)section
                            withIndex:(NSInteger)index;

/**
 获取数据源中的地址名字

 @param array 数据源
 @param index 索引
 @return 地址联系人名称
 */
+ (NSString *)getAddressNameFromArray:(NSArray *)array
                          withSection:(NSInteger)section
                            withIndex:(NSInteger)index;

/**
 获取联系电话

 @param array 数据源
 @param index 索引
 @return 地址联系人电话
 */
+ (NSString *)getAddressPhoneFromArray:(NSArray *)array
                           withSection:(NSInteger)section
                             withIndex:(NSInteger)index;

/**
 获取收货地址详情

 @param array 数据源
 @param index 索引
 @return 地址详情
 */
+ (NSString *)getAddressDetailFromArray:(NSArray *)array
                            withSection:(NSInteger)section
                              withIndex:(NSInteger)index;

/**
 是否是默认地址

 @param array 数据源
 @param index 索引
 @return YES:是默认地址
 */
+ (BOOL)isDefaultAddressFromArray:(NSArray *)array
                      withSection:(NSInteger)section
                        withIndex:(NSInteger)index;

/**
 是否是已选择的地址

 @param array 数据源
 @param index 索引
 @param selectedId 选择的地址ID
 @return YES:是选择的地址
 */
+ (BOOL)isSelectedAddressFromArray:(NSArray *)array
                       withSection:(NSInteger)section
                         withIndex:(NSInteger)index
                     andSelectedId:(NSString *)selectedId;

/**
 根据id获取地址

 @param addressId 地址id
 @param array 数据源
 @return 地址模型
 */
+ (ESAddress *)getAddressWithId:(NSString *)addressId
                      fromArray:(NSArray *)array;
@end
