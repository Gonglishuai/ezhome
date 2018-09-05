//
//  ESStockKeepingUnit.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESStockKeepingUnit.h"
#import "CoStringManager.h"

@implementation ESStockKeepingUnit

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name  = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.value = [CoStringManager judgeNSString:dict forKey:@"value"];
        self.nameId  = [CoStringManager judgeNSString:dict forKey:@"nameId"];
        self.valueId = [CoStringManager judgeNSString:dict forKey:@"valueId"];
    }
    return self;
}

+ (instancetype)objFormDict:(NSDictionary *)dict {
    return [[ESStockKeepingUnit alloc] initWithDict:dict];
}
@end
