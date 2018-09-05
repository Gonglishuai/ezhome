//
//  ESDevice.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESDeviceSizeType)
{
    ESDeviceSizeTypeUnknow,
    ESDeviceSizeTypeIphone4,
    ESDeviceSizeTypeIphone5,
    ESDeviceSizeTypeIphone6And7,
    ESDeviceSizeTypeIphonePlus,
    ESDeviceSizeTypeIphone8,
    ESDeviceSizeTypeIphoneX,
};

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ESDevice : NSObject

+ (ESDevice *)currentDevice;

//App状态
+ (BOOL)isInBackground;

+ (NSInteger)cpuCount;

+ (BOOL)isLowDevice;
+ (BOOL)isIphone;
+ (NSString *)machineName;


+ (CGFloat)statusBarHeight;

+ (ESDeviceSizeType)deviceSizeType;//设备类型
+ (NSString *)deviceModel;
+ (float)deviceVersion;//设备版本号
+ (NSString *)createUUID;//创建设备唯一标示
@end
