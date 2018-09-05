//
//  ESCaseProductModel.m
//  Consumer
//
//  Created by jiang on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESCaseProductModel.h"
#import "CoStringManager.h"

@implementation ESCaseProductModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.catentryId   = [CoStringManager judgeNSString:dict forKey:@"catentryId"];
        self.skuName      = [CoStringManager judgeNSString:dict forKey:@"skuName"];
        self.imgUrl       = [CoStringManager judgeNSString:dict forKey:@"imgUrl"];
        self.catentrySpuId   = [CoStringManager judgeNSString:dict forKey:@"catentrySpuId"];
        
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCaseProductModel alloc] initWithDict:dict];
}

@end
