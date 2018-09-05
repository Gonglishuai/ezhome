//
//  JRLocationServices.h
//  Consumer
//
//  Created by jiang on 2017/6/19.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRCityInfo.h"

typedef void (^LocationBlock)(JRCityInfo*);

@interface JRLocationServices : NSObject

+ (instancetype)sharedInstance;
- (void)setUpApiKey;


/**
 获取定位

 @param block 城市信息
 */
- (void)requestLocation:(LocationBlock)block;

@property(strong, nonatomic) JRCityInfo *locationCityInfo;//定位城市

@property(strong, nonatomic) JRCityInfo *currentCityInfo;//选择城市

@end
