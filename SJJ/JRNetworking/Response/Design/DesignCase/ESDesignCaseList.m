//
//  ESDesignCaseList.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/6.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignCaseList.h"
#import "ESModel.h"
#import <ESFile.h>

@implementation ESDesignCaseList

+ (instancetype)objFromDict:(NSDictionary *)dict {
    @try {
        ESDesignCaseList *caseModel =  [ESDesignCaseList es_modelWithJSON:dict];
        [self updateData:caseModel];
        return caseModel;
    } @catch (NSException *exception) {
        SHLog(@"%@", exception.description);
        return nil;
    }
}

+ (void)updateData:(ESDesignCaseList *)model
{
    if (!model
        || ![model isKindOfClass:[ESDesignCaseList class]])
    {
        return;
    }
    
    model.designCover = [ESFile getImageUrl:model.designCover
                                   withType:ESFileTypeHD];
}

@end
