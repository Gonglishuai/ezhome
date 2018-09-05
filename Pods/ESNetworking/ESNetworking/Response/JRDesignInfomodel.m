//
//  JRDesignInfomodel.m
//  Consumer
//
//  Created by jiang on 2017/5/5.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRDesignInfomodel.h"

@implementation JRDesignInfomodel

+ (id)createModelWithDic:(NSDictionary *)dic {
    return [[JRDesignInfomodel alloc] initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:dic];
            
            NSMutableArray *array = [NSMutableArray array];
            if (![dic[@"order"] isKindOfClass:[NSNull class]]) {
                for (NSDictionary *dict in dic[@"order"]) {
                    JRDesignOrderInfomodel *model = [JRDesignOrderInfomodel createModelWithDic:dict];
                    [array addObject:model];
                }
                self.order = (id)array;
            } else {
                self.order = array;
            }
            
            self.d3Cases = [NSMutableArray array];
            if (dic  && ![dic isKindOfClass:[NSNull class]] && dic[@"d3Cases"] && ![dic[@"d3Cases"] isKindOfClass:[NSNull class]]) {
                for (NSDictionary *dict in dic[@"d3Cases"]) {
                    ESDesignProject3DCase *d3Case = [ESDesignProject3DCase objFromDict:dict];
                    [self.d3Cases addObject:d3Case];
                }
            }
            
        } else {
            NSLog(@"传入的数据源有误!");
        }
    }
    return self;
}

@end

