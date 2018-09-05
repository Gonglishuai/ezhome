/**
 * @file    MPRegionModel.h
 * @brief   the model of region.
 * @author  Jiao
 * @version 1.0
 * @date    2016-03-13
 *
 */

#import <Foundation/Foundation.h>

@interface MPRegionModel : NSObject

/// the abbreviation of region name.
@property (nonatomic, copy) NSString *abbname;

/// the name of region.
@property (nonatomic, copy) NSString *region_name;

/// the code of region.
@property (nonatomic, copy) NSString *code;

/// the parent code of region.
@property (nonatomic, copy) NSString *parent_code;

/// the type of region.
@property (nonatomic, copy) NSString *region_type;

/// the zipcode of region.
@property (nonatomic, copy) NSString *zip;

/**
 *  @brief dictonary to model.
 *
 *  @param dict the dictonary of data.
 *
 *  @return the model of region.
 */
+ (MPRegionModel *)getRegionModelWithDict:(NSDictionary *)dict;
@end
