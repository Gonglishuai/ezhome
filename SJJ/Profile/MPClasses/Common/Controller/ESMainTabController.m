//
//  ESMainTabController.m
//  Mall
//
//  Created by 焦旭 on 2017/8/29.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMainTabController.h"
#import "ESNIMManager.h"
#import "ESNavigationController.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"
#define TabBarCount 4

typedef NS_ENUM(NSInteger, ESMainTabType) {
    ESMainTabTypeMall,           //商城
    ESMainTabTypeFittingRoom,    //家装试衣间
//    ESMainTabTypeSupermarket,    //丽屋超市
    ESMainTabTypeShoppingCart,   //购物车
    ESMainTabTypeMine,           //我
};

@interface ESMainTabController ()<ESNIMManagerDelegate>

@property (nonatomic,copy)  NSDictionary *configs;
@end

@implementation ESMainTabController

+ (instancetype)instance {
    AppDelegate *delegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = delegete.window.rootViewController;
    if ([vc isKindOfClass:[ESMainTabController class]]) {
        return (ESMainTabController *)vc;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ESNIMManager sharedManager] addESIMDelegate:self];
    self.tabBar.translucent = NO;
    [self setUpSubNav];
}

- (NSArray*)tabbars{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSInteger tabbar = 0; tabbar < TabBarCount; tabbar++) {
        [items addObject:@(tabbar)];
    }
    return items;
}

- (void)setUpSubNav{
    NSMutableArray *vcArray = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item =[self vcInfoForTabType:[obj integerValue]];
        NSString *vcName = item[TabbarVC];
        NSString *title  = item[TabbarTitle];
        NSString *imageName = item[TabbarImage];
        NSString *imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        UIViewController *vc = [[clazz alloc] initWithNibName:nil bundle:nil];
        vc.hidesBottomBarWhenPushed = NO;
        ESNavigationController *nav = [[ESNavigationController alloc] initWithRootViewController:vc];
        nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title
                                                       image:[[UIImage imageNamed:imageName]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                               selectedImage:[[UIImage imageNamed:imageSelected]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
        [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
        [nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -1)];
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
        
        [vcArray addObject:nav];
    }];
    self.viewControllers = [NSArray arrayWithArray:vcArray];
}

- (void)refreshTabbar {
    NSInteger unread = [[ESNIMManager sharedManager] getNIMAllUnreadCount];
    [self hasNewMessage:unread > 0];
}
#pragma mark - VC
- (NSDictionary *)vcInfoForTabType:(ESMainTabType)type{
    
    if (_configs == nil)
    {
        _configs = @{
                     @(ESMainTabTypeMall)           : @{
                                TabbarVC            : @"ESMasterialHomeController",
                                TabbarTitle         : @"首页",
                                TabbarImage         : @"tab_bar_home",
                                TabbarSelectedImage : @"tab_bar_home_s",
                                TabbarItemBadgeValue: @(0)
                                },
                     @(ESMainTabTypeFittingRoom)    : @{
                                TabbarVC            : @"ESCaseFittingRoomHomeViewController",
                                TabbarTitle         : @"家装试衣间",
                                TabbarImage         : @"tab_bar_fitting",
                                TabbarSelectedImage : @"tab_bar_fitting_s",
                                TabbarItemBadgeValue: @(0)
                                },
//                     @(ESMainTabTypeSupermarket)    : @{
//                                TabbarVC            : @"MarketViewController",
//                                TabbarTitle         : @"丽屋超市",
//                                TabbarImage         : @"tab_bar_material",
//                                TabbarSelectedImage : @"tab_bar_material_s",
//                                },
                     @(ESMainTabTypeShoppingCart)   : @{
                                TabbarVC            : @"ESShoppingCartController",
                                TabbarTitle         : @"购物车",
                                TabbarImage         : @"tab_bar_shopcar",
                                TabbarSelectedImage : @"tab_bar_shopcar_s",
                                TabbarItemBadgeValue: @(0)
                                },
                     @(ESMainTabTypeMine)           : @{
                                TabbarVC            : @"ESPersonalCenterController",
                                TabbarTitle         : @"我",
                                TabbarImage         : @"tab_bar_mine",
                                TabbarSelectedImage : @"tab_bar_mine_s",
                                TabbarItemBadgeValue: @(0)
                                }
                     };
        
    }
    return _configs[@(type)];
}

#pragma mark - ESNIMManagerDelegate
- (void)hasNewMessage:(BOOL)newMsg {
    ESNavigationController *nav = self.viewControllers[ESMainTabTypeMine];
    NSString *imgStr = newMsg ? @"tab_bar_mine_new" : @"tab_bar_mine";
    NSString *imgSelStr = newMsg ? @"tab_bar_mine_new_s" : @"tab_bar_mine_s";
    [nav.tabBarItem setImage:[[UIImage imageNamed:imgStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [nav.tabBarItem setSelectedImage:[[UIImage imageNamed:imgSelStr] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
}
@end
