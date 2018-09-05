//
//  ESEditAddressViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/6/29.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESAddress.h"

@interface ESEditAddressViewModel : NSObject

/**
 获取地址联系人姓名

 @param address 数据源
 @return 姓名
 */
+ (NSString *)getAddressName:(NSDictionary *)address;


/**
 获取地址联系人电话
 
 @param address 数据源
 @return 电话
 */
+ (NSString *)getAddressPhone:(NSDictionary *)address;


/**
 获取省市区信息
 
 @param address 数据源
 @return 省-市-区
 */
+ (NSString *)getLocation:(NSDictionary *)address;


/**
 获取地址详情
 
 @param address 数据源
 @return 详情
 */
+ (NSString *)getAddressDetail:(NSDictionary *)address;

/**
 是否为默认地址
 
 @param address 数据源
 @return YES:是默认地址
 */
+ (BOOL)isDefaultAddress:(NSDictionary *)address;

/**
 
 
 @param addressDict
 @param address
 */

/**
 保存地址

 @param addressDict 地址信息的字典
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)saveAddress:(NSDictionary *)addressDict
        withAddress:(ESAddress *)address
        withSuccess:(void(^)(NSString *successMsg))success
         andFailure:(void(^)(NSString *errorMsg))failure;

/**
 获取地址信息字典

 @param address 地址模型
 @return 信息字典
 */
+ (NSMutableDictionary *)getInfoFromAddress:(ESAddress *)address;

/**
 更新地址信息

 @param dict 信息字典
 @param curInfo 当前存储的信息
 @return 地址
 */
+ (NSMutableDictionary *)updateAddressInfoWithDict:(NSDictionary *)dict
                                   withCurrentInfo:(NSDictionary *)curInfo;

/**
 检查输入项

 @param dict 数据源
 @return 错误信息，没有返回nil
 */
+ (NSString *)checkInputWithDict:(NSDictionary *)dict;
@end
