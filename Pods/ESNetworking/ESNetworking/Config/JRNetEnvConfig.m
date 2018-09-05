//
//  JRNetEnvConfig.m
//  Consumer
//
//  Created by jiang on 2017/6/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRNetEnvConfig.h"

@implementation JRNetEnvConfig

#pragma mark - Instance
+ (instancetype)sharedInstance {
    static JRNetEnvConfig *config = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        config = [[super allocWithZone:NULL]init];
    });
    
    return config;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {

    return [JRNetEnvConfig sharedInstance];
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [JRNetEnvConfig sharedInstance];
}


@end
