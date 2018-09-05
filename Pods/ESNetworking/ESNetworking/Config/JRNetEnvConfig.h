//
//  JRNetEnvConfig.h
//  Consumer
//
//  Created by jiang on 2017/6/13.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRNetEnvModel.h"

@interface JRNetEnvConfig : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, assign) BOOL isReleaseModel;
@property (nonatomic, strong) JRNetEnvModel *netEnvModel;
@end
