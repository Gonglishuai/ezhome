//
//  CoTabBarControllerManager.h
//  Consumer
//
//  Created by Jiao on 16/8/16.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ESTabType)
{
    ESTabTypeUnKnow = 0,
    ESTabTypeConsumer,
    ESTabTypeDesigner
};

@interface CoTabBarControllerManager : NSObject

@property (nonatomic, assign) ESTabType tabType;

@property (nonatomic, strong, readonly) UITabBarController *tabBarController;

@property (nonatomic, strong, readonly) UIImage *backImage;

@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *selectedIndexs;


+ (instancetype)tabBarManager;

- (void)tabBarController:(UITabBarController *)tbVC;

- (void)chageToConsumerMode;

- (void)chageToDesignerMode;

- (void)setCurrentController:(NSInteger)index;

- (void)selectedTabBar:(UITabBarController *)tbVC viewController:(UIViewController *)viewController;

- (void)changeTabBarSelectedIndex:(NSUInteger)tabIndex;

- (void)changeTabBarSelectedIndex:(NSUInteger)tabIndex;


@end
