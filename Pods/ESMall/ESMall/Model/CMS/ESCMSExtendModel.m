//
//  ESCMSExtendModel.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCMSExtendModel.h"
#import "ESModel.h"

@implementation ESCMSExtendModel

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESCMSExtendModel es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

@end
