//
//  ESMallAssets.h
//  ESMall
//
//  Created by 焦旭 on 2017/11/28.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESMallAssets : NSObject

/**
 取组件bundle
 
 @return 组件bundle
 */
+(NSBundle *)hostBundle;


/**
 取组件图片
 
 @param imgName 图片名字
 @return 图片
 */
+ (UIImage *)bundleImage:(NSString *)imgName;
@end
