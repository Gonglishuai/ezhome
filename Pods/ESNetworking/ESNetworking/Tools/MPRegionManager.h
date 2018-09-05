/**
 * @file    MPRegionManager.h
 * @brief   the manager of region query.
 * @author  Jiao
 * @version 1.0
 * @date    2016-03-13
 *
 */

#import <Foundation/Foundation.h>

@class MPRegionModel;
typedef enum : NSUInteger {
    MPRegionForNone = 1,    //!< no type for region.
    MPRegionForProvince,    //!< the type of region is province.
    MPRegionForCity,        //!< the type of region is city.
    MPRegionForDistrict     //!< the type of region is district.
} MPRegionType ;

@interface MPRegionManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  @brief get the region name and code by its parent code.
 *
 *  @param type the type of region.
 *
 *  @param parent_code the parent code of region.
 *
 *  @return array of regions.
 */
- (NSArray <MPRegionModel *>*)getRegionWithType:(MPRegionType)type withParentCode:(NSString *)parent_code;


/**
 query the region name by code

 @param province_code province_code the code of province
 @param city_code province_code the code of city
 @param district_code province_code the code of district
 @return the dictionary of region names as [@"province":@"province_name", @"city":@"city_name", @"district":@"district_name"].
 */
- (NSDictionary *)getRegionWithProvinceCode:(NSString *)province_code
                               withCityCode:(NSString *)city_code
                            andDistrictCode:(NSString *)district_code;
@end
