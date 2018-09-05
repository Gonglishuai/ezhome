//
//  AppDelegate.h
//  MarketPlace
//
//  Created by xuezy on 15/12/15.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SHPushNotificationTargetType)
{
    SHPushNotificationTargetTypeUnknown = 0,
    SHPushNotificationTargetTypeActivity,
};

@protocol LoginDidRefreshDelegate <NSObject>

- (void)loginDidRefreshData;

@end

@interface SHBaseAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UITabBarController          *tbVC;

@property (strong, nonatomic) UIWindow                    *window;
@property (nonatomic, assign) id<LoginDidRefreshDelegate> loginDelegate;

- (void)initTabbar;
- (void)setTabBarItemSelected;
- (void)handlePushNotification:(NSDictionary *)userInfo;
- (void)handlePushNotificationInForeground:(NSDictionary *)userInfo;
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;
- (void)resetTabViews;

- (UIImage *) getDefaultUserAvatarImage;

@end

