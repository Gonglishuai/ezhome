//
//  ESPublicMethods.h
//  ESFoundation
//
//  Created by jiang on 2017/11/8.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESNavigationController.h"

@interface ESPublicMethods : NSObject
+ (ESNavigationController *)getCurrentNavigationController;
+ (UIViewController*)currentViewController;
@end
