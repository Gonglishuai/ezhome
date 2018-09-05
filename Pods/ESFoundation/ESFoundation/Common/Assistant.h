//
//  Assistant.h
//  Consumer
//
//  Created by jiang on 2017/5/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Assistant : NSObject

//H5跳转Native
+ (void)handleOpenURL:(NSURL *)url viewController:(UIViewController *)viewController;

//3D漫游跳转Native
+ (void)handleOpen3DURL:(NSURL *)url viewController:(UIViewController *)viewController;

//商城之后showCase跳转
+ (void)jumpWithShowCaseDic:(NSDictionary *)dic viewController:(UIViewController *)viewController;

@end
