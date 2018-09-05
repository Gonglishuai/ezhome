//
//  ESPublicMethods.m
//  ESFoundation
//
//  Created by jiang on 2017/11/8.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "ESPublicMethods.h"

@implementation ESPublicMethods
+ (ESNavigationController *)getCurrentNavigationController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        return (ESNavigationController *)rootVC;
    } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)rootVC;
        ESNavigationController *nav = (ESNavigationController *)tab.selectedViewController;
        return nav;
    } else {
        return (ESNavigationController *)rootVC.navigationController;
    }
}

+ (UIViewController*)currentViewController{
    
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            
            vc = ((UITabBarController*)vc).selectedViewController;
            
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            
            vc = ((UINavigationController*)vc).visibleViewController;
            
        }
        if (vc.presentedViewController) {
            
            vc = vc.presentedViewController;
            
        }else{
            break;
        }
    }
    return vc;
}

@end
