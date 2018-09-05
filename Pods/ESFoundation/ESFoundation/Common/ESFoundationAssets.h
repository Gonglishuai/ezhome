//
//  ESFoundationAssets.h
//  ESFoundation
//
//  Created by jiang on 2017/11/7.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ESFoundationAssets : NSObject

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
