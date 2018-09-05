//
//  ES2DCaseDetail.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ES2DCaseDetail.h"
#import "ESModel.h"

@implementation ESCaseDesignerInfo

@end

@implementation ES2DCaseDetail

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ES2DCaseDetail es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}
@end
