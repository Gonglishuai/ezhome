//
//  ESMyMessageModel.m
//  Consumer
//
//  Created by zhangdekai on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMyMessageModel.h"
#import "CoStringManager.h"

@implementation ESMyMessageModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.receiver = [CoStringManager judgeNSString:dic forKey:@"receiver"];
        self.theme = [CoStringManager judgeNSString:dic forKey:@"theme"];
        self.content = [CoStringManager judgeNSString:dic forKey:@"content"];
        self.sender = [CoStringManager judgeNSString:dic forKey:@"sender"];
        self.sendTime = [CoStringManager judgeNSString:dic forKey:@"sendTime"];
        self.readStatus = [CoStringManager judgeNSInteger:dic forKey:@"readStatus"];
    }
    return self;
}

+ (NSMutableArray<ESMyMessageModel *> *)getmodelArrayWithDic:(NSDictionary *)dic {
    
    NSMutableArray *datasource = [NSMutableArray new];
    
    if ([dic isKindOfClass:[NSDictionary class]] && dic.count > 0) {
        NSArray *mesages = dic[@"data"];
        if (mesages && mesages.count > 0) {
            for (NSDictionary *contentDic in mesages) {
                ESMyMessageModel *model = [[ESMyMessageModel alloc]initWithDic:contentDic];
                [datasource addObject:model];
            }
        }
    }
    return datasource;
}


@end
