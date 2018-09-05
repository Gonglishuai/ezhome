//
//  ESFilterItem.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilterItem.h"
#import "ESModel.h"

@implementation ESFilterItem

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESFilterItem es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (NSDictionary *)dictFromObj:(ESFilterItem *)obj {
    @try {
        return [obj es_modelToJSONObject];
    } @catch (NSException *exception) {
        
        return nil;
    }
}
@end
