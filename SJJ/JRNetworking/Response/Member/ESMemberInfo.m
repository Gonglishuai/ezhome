//
//  ESMemberInfo.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfo.h"
#import "ESModel.h"

@implementation ESMemberInfo

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESMemberInfo es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (NSDictionary *)dictFromObj:(ESMemberInfo *)obj {
    @try {        
        return [obj es_modelToJSONObject];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}

@end
