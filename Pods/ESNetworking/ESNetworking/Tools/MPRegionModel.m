/**
 * @file    MPRegionModel.m
 * @brief   the model of region.
 * @author  Jiao
 * @version 1.0
 * @date    2016-03-13
 *
 */

#import "MPRegionModel.h"

@implementation MPRegionModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (MPRegionModel *)getRegionModelWithDict:(NSDictionary *)dict {
    return [[MPRegionModel alloc]initWithDict:dict];
}
@end
