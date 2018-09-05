//
//  ESAddress.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESAddress.h"
#import "CoStringManager.h"

@implementation ESAddress

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.addressId      = [CoStringManager judgeNSString:dict forKey:@"addressId"];
        self.memberId       = [CoStringManager judgeNSString:dict forKey:@"memberId"];
        self.name           = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.phone          = [CoStringManager judgeNSString:dict forKey:@"phone"];
        self.email          = [CoStringManager judgeNSString:dict forKey:@"email"];
        self.province       = [CoStringManager judgeNSString:dict forKey:@"province"];
        self.provinceCode   = [CoStringManager judgeNSString:dict forKey:@"provinceCode"];
        self.city           = [CoStringManager judgeNSString:dict forKey:@"city"];
        self.cityCode       = [CoStringManager judgeNSString:dict forKey:@"cityCode"];
        self.district       = [CoStringManager judgeNSString:dict forKey:@"district"];
        self.districtCode   = [CoStringManager judgeNSString:dict forKey:@"districtCode"];
        self.addressInfo    = [CoStringManager judgeNSString:dict forKey:@"addressInfo"];
        self.zipcode        = [CoStringManager judgeNSString:dict forKey:@"zipcode"];
        self.isPrimary      = [CoStringManager judgeBOOL:dict forKey:@"isPrimary"];
        self.longitude      = [CoStringManager judgeNSString:dict forKey:@"longitude"];
        self.latitude       = [CoStringManager judgeNSString:dict forKey:@"latitude"];
        self.createTime     = [CoStringManager judgeNSString:dict forKey:@"createTime"];
        self.lastUpdate     = [CoStringManager judgeNSString:dict forKey:@"lastUpdate"];
    }
    return self;
}

+ (instancetype)objFromDict: (NSDictionary *)dict {
    ESAddress *address = [[ESAddress alloc] initWithDict:dict];
    return address;
}
@end
