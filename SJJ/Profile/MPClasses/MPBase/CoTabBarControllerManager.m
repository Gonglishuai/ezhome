//
//  CoTabBarControllerManager.m
//  Consumer
//
//  Created by Jiao on 16/8/16.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import "CoTabBarControllerManager.h"
#import "CoHomeBaseViewController.h"
#import "MPDesignerlist.h"
#import "CoTabBarHeader.h"
#import "HomePageDesignerViewController.h"
//#import "HomePageConsumerViewController.h"
#import "ESPersonalCenterController.h"
#import "ESMasterialHomeController.h"
#import "MPFindDesignersViewController.h"
#import "ESNavigationController.h"
#import "EZHome-Swift.h"

@interface CoTabBarControllerManager()
@property (nonatomic, strong, readwrite) UITabBarController *tabBarController;
@property (nonatomic, strong, readwrite) UIImage *backImage;//被选中的tabBar背景图，用作高斯模糊（for 套餐）
@property (nonatomic, strong, readwrite) NSMutableArray<NSString *> *selectedIndexs;//承载选中的tabBarIndex

@end
@implementation CoTabBarControllerManager
{
    //首页
//    ESNavigationController *_homePageConsumer_nav;
    ESNavigationController *_homePageConsumer_nav;
    
    ESNavigationController *_homePageDesigner_nav;
    //案例
    ESNavigationController *_example_nav;
    //我要装修
    ESNavigationController *_decoration_nav;
    //应标大厅
    ESNavigationController *_response_nav;
    //商城
    ESNavigationController *_material_nav;
    //我
    ESNavigationController *_mine_nav;
    //设计师
    ESNavigationController *_desingers_nav;
}

+ (instancetype)tabBarManager {
    static CoTabBarControllerManager *s_request = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        s_request = [[super allocWithZone:NULL]init];
        [s_request initNavigationController];
    });
    
    return s_request;
}

///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [CoTabBarControllerManager tabBarManager];
}

///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [CoTabBarControllerManager tabBarManager];
}

- (void)tabBarController:(UITabBarController *)tbVC {
    self.tabBarController = tbVC;
    [self settingTabBarController:tbVC];
}

- (void)selectedTabBar:(UITabBarController *)tbVC viewController:(UIViewController *)viewController {
   
    if (self.tabType == ESTabTypeConsumer) {
        
        [_tabBarController.tabBar setHidden:NO];
        
        NSUInteger tabIndex = tbVC.selectedIndex;
        
        switch (tabIndex) {
            case 0:
                _backImage = [self captureImageFromView:_homePageConsumer_nav.view];
                break;
            case 1:
                _backImage = [self captureImageFromView:_example_nav.view];
                break;
            case 3:
                _backImage = [self captureImageFromView:_material_nav.view];
                break;
            case 4:
                _backImage = [self captureImageFromView:_mine_nav.view];
                break;
            default:
                [_tabBarController.tabBar setHidden:YES];
                break;
        }
    }
}

- (void)changeTabBarSelectedIndex:(NSUInteger)tabIndex
{
    if (_selectedIndexs.count == 1) {
        [_selectedIndexs addObject:[NSString stringWithFormat:@"%ld",tabIndex]];
        _backImage = [self captureImageFromView:_homePageConsumer_nav.view];
    } else if (_selectedIndexs.count == 2){
        if (_selectedIndexs[1].integerValue != tabIndex) {
            [_selectedIndexs removeObjectAtIndex:0];
            [_selectedIndexs addObject:[NSString stringWithFormat:@"%ld",tabIndex]];
        }
    }
}

#pragma mark - Lazy Loading

- (void)settingTabBarController:(UITabBarController *)tbVC {
//    tbVC.tabBar.opaque = YES;
    tbVC.tabBar.alpha = 0.9;
    [tbVC.tabBar setBackgroundColor:[UIColor stec_tabbarBackgroundColor]];
//    CGRect rect = CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT, SCREEN_WIDTH, TABBAR_HEIGHT);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [tbVC.tabBar setBackgroundImage:img];
//    [tbVC.tabBar setShadowImage:img];
}

- (void)initNavigationController {
    
    _selectedIndexs = [NSMutableArray arrayWithCapacity:2];
    [_selectedIndexs addObject:@"0"];
    
    //商城
    _material_nav = nil;
    ESMasterialHomeController * material = [[ESMasterialHomeController alloc]init];
    _material_nav= [[ESNavigationController alloc] initWithRootViewController:material];
    _material_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_MATERIAL] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _material_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_MATERIAL_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _material_nav.tabBarItem.title = TAB_BAR_MATERIAL_TITLE;
    [_material_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_material_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_material_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
    //我
    _mine_nav = nil;
    ESPersonalCenterController * mine = [[ESPersonalCenterController alloc]init];
    _mine_nav= [[ESNavigationController alloc] initWithRootViewController:mine];
    _mine_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_MINE]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _mine_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_MINE_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _mine_nav.tabBarItem.title = TAB_BAR_MINE_TITLE;
    [_mine_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_mine_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_mine_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
}

//- (void)refreshPublicControllers {
//    //聊天列表
//    _chatList_nav = nil;
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CoChatRoomList" bundle: nil ];
//    SHChatListViewController *vc2 = [storyBoard instantiateInitialViewController];
//    _chatList_nav= [[UINavigationController alloc] initWithRootViewController:vc2];
//    _chatList_nav.tabBarItem.image = [UIImage imageNamed:TAB_BAR_CHAT];
//    _chatList_nav.tabBarItem.selectedImage = [UIImage imageNamed:TAB_BAR_CHAT_SELECTION];
//    _chatList_nav.tabBarItem.title = TAB_BAR_CHAT_TITLE;
//    [_chatList_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
//}

- (void)refreshDesignerControllers {
//    [self refreshPublicControllers];
    
    //首页（设计师）
    HomePageDesignerViewController *homePageDesigner = [[HomePageDesignerViewController alloc] init];
    _homePageDesigner_nav = [[ESNavigationController alloc] initWithRootViewController:homePageDesigner];
    _homePageDesigner_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_HOME]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homePageDesigner_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_HOME_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homePageDesigner_nav.tabBarItem.title = TAB_BAR_HOME_TITLE;
    [_homePageDesigner_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_homePageDesigner_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_homePageDesigner_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
    //设计师
    _desingers_nav = nil;
    MPFindDesignersViewController * desingers = [[MPFindDesignersViewController alloc]init];
    desingers.isHiddenLeft = YES;
    _desingers_nav= [[ESNavigationController alloc] initWithRootViewController:desingers];
    _desingers_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_DESIGNER] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _desingers_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_DESIGNER_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _desingers_nav.tabBarItem.title = TAB_BAR_DESIGNER_TITLE;
    [_desingers_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_desingers_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_desingers_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
    //应标大厅
    _response_nav = nil;
    MPDesignerlist *response = [[MPDesignerlist alloc] init];
    _response_nav= [[ESNavigationController alloc] initWithRootViewController:response];
    _response_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_RESPONE]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _response_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_RESPONE_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _response_nav.tabBarItem.title = TAB_BAR_RESPONE_TITLE;
    [_response_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_response_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_response_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];

}

- (void)refreshConsumerControllers {
//    [self refreshPublicControllers];
    //首页（消费者）
    ESProHomePageController *homePageConsumer = [[ESProHomePageController alloc] init];
    _homePageConsumer_nav = [[ESNavigationController alloc] initWithRootViewController:homePageConsumer];
    _homePageConsumer_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_HOME]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homePageConsumer_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_HOME_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homePageConsumer_nav.tabBarItem.title = TAB_BAR_HOME_TITLE;
    [_homePageConsumer_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_homePageConsumer_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_homePageConsumer_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
    //案例      NSForegroundColorAttributeName:[UIColor stec_tabbarNormalTextColor]
    CoHomeBaseViewController *example = [[CoHomeBaseViewController alloc] init];
    _example_nav = [[ESNavigationController alloc] initWithRootViewController:example];
    [_example_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_example_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    _example_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_EXAMPLE]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _example_nav.tabBarItem.selectedImage = [[UIImage imageNamed:TAB_BAR_EXAMPLE_SELECTION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _example_nav.tabBarItem.title = TAB_BAR_EXAMPLE_TITLE;
    [_example_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
    //我的项目（消费者）
//    _myDecoration_nav = nil;
//    CoMyDecorationProjectController *vc3 = [[CoMyDecorationProjectController alloc] init];
//    _myDecoration_nav= [[UINavigationController alloc] initWithRootViewController:vc3];
//    _myDecoration_nav.tabBarItem.image = [UIImage imageNamed:TAB_BAR_COPROJECT];
//    _myDecoration_nav.tabBarItem.selectedImage = [UIImage imageNamed:TAB_BAR_COPROJECT_SELECTION];
//    _myDecoration_nav.tabBarItem.title = TAB_BAR_COPROJECT_TITLE;
//    [_myDecoration_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-3, -3)];
    //我要装修 (消费者)
    _decoration_nav = nil;
    
    ESPackageMainViewController *vc5 = [[ESPackageMainViewController alloc]init];
    
    _decoration_nav= [[ESNavigationController alloc] initWithRootViewController:vc5];
    _decoration_nav.tabBarItem.image = [[UIImage imageNamed:TAB_BAR_DECORATION]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    _decoration_nav.tabBarItem.selectedImage = [UIImage imageNamed:TAB_BAR_DECORATION_SELECTION];
    _decoration_nav.tabBarItem.title =TAB_BAR_DECORATION_TITLE;
//    UIEdgeInsets inset = UIEdgeInsetsMake(-10, 0, 10, 0);
//    _decoration_nav.tabBarItem.imageInsets = inset;
    [_decoration_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarNormalTextColor]} forState:UIControlStateNormal];
    [_decoration_nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont stec_tabbarFount], NSForegroundColorAttributeName: [UIColor stec_tabbarTextColor]} forState:UIControlStateHighlighted];
    [_decoration_nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(-4, -4)];
    
}


- (void)chageToConsumerMode {
    self.tabType = ESTabTypeConsumer;
    
    [self refreshConsumerControllers];
    self.tabBarController.viewControllers = @[_homePageConsumer_nav, _example_nav, _decoration_nav, _material_nav, _mine_nav];
    [self.tabBarController.tabBar layoutSubviews];
}

- (void)chageToDesignerMode {
    self.tabType = ESTabTypeDesigner;
    
    [self refreshDesignerControllers];
    self.tabBarController.viewControllers = @[_homePageDesigner_nav, _desingers_nav, _response_nav, _material_nav, _mine_nav];
    [self.tabBarController.tabBar layoutSubviews];
}

- (void)setCurrentController:(NSInteger)index {
    if (self.tabBarController.viewControllers.count > index) {
        self.tabBarController.selectedIndex = index;
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[index];
        [_tabBarController.tabBar setHidden:NO];
    }
}

//截图功能

- (UIImage *)captureImageFromView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.frame.size,NO, 0);
    
    [[UIColor clearColor] setFill];
    
    [[UIBezierPath bezierPathWithRect:view.bounds] fill];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

@end
