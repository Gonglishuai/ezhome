//
//  ESCMSModel.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCMSModel.h"
#import "ESModel.h"

@implementation ESCMSModel

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESCMSModel es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (NSDictionary *)dictFromObj:(ESCMSModel *)object {
    @try {
        NSDictionary *dict = [object es_modelToJSONObject];
        return dict;
    } @catch (NSException *exception) {
        return nil;
    }
}
@end
