//
//  ESMainTabController.h
//  Mall
//
//  Created by 焦旭 on 2017/8/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//
//  tabbar主控制器

#import <UIKit/UIKit.h>

@interface ESMainTabController : UITabBarController

+ (instancetype)instance;

- (void)refreshTabbar;
@end
