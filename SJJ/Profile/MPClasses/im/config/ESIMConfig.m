//
//  ESIMConfig.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESIMConfig.h"

@implementation ESIMConfig

+ (instancetype)sharedConfig {
    static ESIMConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ESIMConfig alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //Alpha UAT
//        _appKey = @"73e4c1f34835efda573b99ae77fcb7a7";
//        _apnsCername = @"CONSUMER";
        
        //Shejijia
        _appKey = @"d69b587ae0ddb613b253cc33e8a98228";
        _apnsCername = @"Shejijia";
    }
    return self;
}

@end
