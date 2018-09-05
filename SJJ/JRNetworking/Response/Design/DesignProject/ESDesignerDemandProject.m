//
//  ESDesignerDemandProject.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignerDemandProject.h"
#import "ESModel.h"

@implementation ESDesignerDemandProject

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        return [ESDesignerDemandProject es_modelWithJSON:dict];
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}
@end
