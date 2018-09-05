//
//  ESProprietorDemandProject.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESProprietorDemandProject.h"
#import "ESModel.h"

@implementation ESProprietorDemandProject

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESProprietorDemandProject es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}
@end
