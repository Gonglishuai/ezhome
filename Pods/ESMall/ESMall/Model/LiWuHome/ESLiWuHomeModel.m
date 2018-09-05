//
//  ESLiWuHomeModel.m
//  Mall
//
//  Created by 焦旭 on 2017/9/9.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLiWuHomeModel.h"
#import "ESModel.h"

@implementation ESLiWuHomeModel

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESLiWuHomeModel es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"banner" : [ESCMSModel class],
             @"category" : [ESLiWuCategoryModel class] };
}
@end
