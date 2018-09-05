//
//  JRCityInfo.h
//  Consumer
//
//  Created by jiang on 2017/6/19.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRCityInfo : NSObject
/**
 * 定位城市CityName
 */
@property(copy, nonatomic)NSString *locatedCityName;
/**
 * 定位城市编码CityCode
 */
@property(copy, nonatomic)NSString *cityCode;
/**
 * 定位城市经度
 */
@property(copy, nonatomic)NSString *longitude;
/**
 * 定位城市纬度
 */
@property(copy, nonatomic)NSString *latitude;

/**
 * 定位所在区
 */
@property(copy, nonatomic)NSString *district;

/**
 * 定位所在区
 */
@property(copy, nonatomic)NSString *districtCode;

/**
 * 定位城市所属省/直辖市
 */
@property(copy, nonatomic)NSString *province;

/**
 * 定位城市所属省/直辖市
 */
@property(copy, nonatomic)NSString *provinceCode;


@end
