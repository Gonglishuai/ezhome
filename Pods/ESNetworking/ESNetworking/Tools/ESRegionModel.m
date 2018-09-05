//
//  ESRegionModel.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/10.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESRegionModel.h"
#import "CoStringManager.h"

@implementation ESRegionModel
- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.rid        = [CoStringManager judgeNSString:dict forKey:@"id"];
        self.name       = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.parentId   = [CoStringManager judgeNSString:dict forKey:@"parentId"];
        self.shortName  = [CoStringManager judgeNSString:dict forKey:@"shortName"];
        self.levelType  = [CoStringManager judgeNSString:dict forKey:@"levelType"];
        self.cityCode   = [CoStringManager judgeNSString:dict forKey:@"cityCode"];
        self.zipcode    = [CoStringManager judgeNSString:dict forKey:@"zipcode"];
        self.pinyin     = [CoStringManager judgeNSString:dict forKey:@"pinyin"];
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESRegionModel alloc] initWithDict:dict];
}
@end
