//
//  ESAppConfig.m
//  Mall
//
//  Created by 焦旭 on 2017/9/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESAppConfig.h"
#import "ESModel.h"

@implementation ESAppConfig

- (instancetype)initWithDict:(NSDictionary *)dict {
    @try {
        return [ESAppConfig es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    ESAppConfig *config = [[ESAppConfig alloc] initWithDict:dict];
    NSDictionary *versonDic = [NSDictionary dictionaryWithDictionary:dict[@"ios"]];
    NSString *appVerson = @"1.0.0";
    if (versonDic && versonDic.allKeys.count>0) {
        appVerson = [NSString stringWithFormat:@"%@", versonDic[@"consumerVersionFinance"]?versonDic[@"consumerVersionFinance"]:@"1.0.0"];
    }
    config.consumerVersionFinance = appVerson;
    return config;
}

+ (NSDictionary *)dictFromObj:(ESAppConfig *)obj {
    @try {
        return [obj es_modelToJSONObject];
    } @catch (NSException *exception) {
        
        return nil;
    }
}
@end
