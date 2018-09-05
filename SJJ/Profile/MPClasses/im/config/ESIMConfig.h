//
//  ESIMConfig.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESIMConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic, readonly, strong) NSString *appKey;
@property (nonatomic, readonly, strong) NSString *apnsCername;

@end
