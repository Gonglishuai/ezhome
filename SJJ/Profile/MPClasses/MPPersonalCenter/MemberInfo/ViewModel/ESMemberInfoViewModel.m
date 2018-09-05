//
//  ESMemberInfoViewModel.m
//  Mall
//
//  Created by 焦旭 on 2017/9/1.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMemberInfoViewModel.h"
#import "CoStringManager.h"

@implementation ESMemberInfoViewModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.key     = [CoStringManager judgeNSString:dict forKey:@"key"];
        self.title   = [CoStringManager judgeNSString:dict forKey:@"title"];
        self.edit    = [CoStringManager judgeBOOL:dict forKey:@"edit"];
        self.input   = [CoStringManager judgeBOOL:dict forKey:@"input"];
        self.content = [CoStringManager judgeNSString:dict forKey:@"content"];
        self.keyboardType = [CoStringManager judgeNSInteger:dict forKey:@"keyboardType"];
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESMemberInfoViewModel alloc] initWithDict:dict];
}

+ (NSMutableArray <ESMemberInfoViewModel *>*)getDefaultConfig {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *config = [self getConfig];
    if (config != nil && config.count > 0) {
        for (NSDictionary *dic in config) {
            [array addObject:[ESMemberInfoViewModel objFromDict:dic]];
        }
    }
    
    return array;
}

+ (NSArray *)getConfig {
    NSString *fileName = @"ProprietorInfoConfig";
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        fileName = @"DesignerInfoConfig";
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSArray *data = [[NSArray alloc] initWithContentsOfFile:filePath];
    return data;
}
@end
