//
//  ESAreaModel.h
//  Consumer
//
//  Created by shiyawei on 17/4/18.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESRecommendShareCustomer : NSObject
/// 业主姓名
@property (nonatomic,copy)    NSString *name;
/// 业主手机
@property (nonatomic,copy)    NSString *phone;
///省份code
@property (nonatomic,copy)    NSString *province;
/// 省份名称
@property (nonatomic,copy)    NSString *provinceName;
///城市code
@property (nonatomic,copy)    NSString *city;
///城市名称
@property (nonatomic,copy)    NSString *cityName;
///区code
@property (nonatomic,copy)    NSString *district;
///区名称
@property (nonatomic,copy)    NSString *districtName;
///详细地址
@property (nonatomic,copy)    NSString *detailAddress;


/**
 获取全国省份

 @return array
 */
- (NSArray *)getHolderProvince;

/**
 根据省份code获取全部的城市信息

 @param provinceCode 省份code
 @return array
 */
- (NSArray *)getHolderCityWithProvinceCode:(NSString *)provinceCode;

/**
 根据省份code+城市code获取区code

 @param provinceCode 省份code
 @param cityCode 城市code
 @return array
 */
- (NSArray *)getHolderDistrictWithProvinceCode:(NSString *)provinceCode cityCode:(NSString *)cityCode;

@end
