//
//  ESFilter.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/3.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESFilter.h"
#import "ESModel.h"

@implementation ESFilter

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESFilter es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        
        return nil;
    }
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tagsBeans" : [ESFilterItem class]};
}
@end
