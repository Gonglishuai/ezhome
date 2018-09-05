//
//  DefaultSetting.h
//  ESFoundation
//
//  Created by jiang on 2017/9/5.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 屏幕适配的百分比, 以iPhone6为标准
#define SCREEN_SCALE (SCREEN_WIDTH / 375.0f)
#define TABBAR_HEIGHT 49
#define STATUSBAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NAVBAR_HEIGHT (STATUSBAR_HEIGHT+44)
#define DECORATION_SEGMENT_HEIGHT 40
#define BOTTOM_SAFEAREA_HEIGHT ((STATUSBAR_HEIGHT == 44)?17:0)//底部非安全区域高度

/// WS(weakSelf) self in block.
#define WS(weakSelf)  __weak __block __typeof(&*self)weakSelf = self;

/// 获得 主线程
#define dispatch_async_get_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#ifdef DEBUG // 调试状态打开log功能
#define SHString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define SHLog(...) printf("%s %s[%lf]:\n%s 第%d行:\n%s\n\n", [[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle] UTF8String], [[[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey] UTF8String], [[NSDate date] timeIntervalSince1970],[SHString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else   //发布状态关闭log功能
#define SHLog(...)
#endif
// 端口
#define SHEJIJIA_PORT @"shejijia_port"

#define CASE_IMAGE_RATIO 216/375.0

#define ES_DATABASE @"esshejijia.sqlite"

@interface DefaultSetting : NSObject



@end
