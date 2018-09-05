//
//  ESMainURLServices.m
//  MallDemo
//
//  Created by jiang on 2017/11/8.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESMainURLServices.h"
#import <ESFoundation/ESPublicMethods.h>
#import <MGJRouter/MGJRouter.h>
#import "MBProgressHUD+NJ.h"
#import "ESProductDetailViewController.h"
#import "ESMainTabController.h"
#import "ESSelectListViewController.h"
#import "ESMyGoldViewController.h"
#import "ESMyCouponsViewController.h"
#import "ESCaseDetailViewController.h"
#import "CoCaseDetailController.h"
#import "SHRNViewController.h"
#import <ESFoundationURLServices.h>
#import <ESMallURLServices.h>
#import "ESCreateEnterpriseViewController.h"
#import "ESChooseCouponsViewController.h"
#import "ESAppConfigManager.h"
#import "ESWebViewController.h"
#import "ESNIMManager.h"
#import "ESModelListViewController.h"
#import "CoTabBarControllerManager.h"
#import "ESCaseFittingRoomHomeViewController.h"
#import "CoHomeBaseViewController.h"
#import "MPFindDesignersViewController.h"
#import "ESLiWuMarketController.h"
#import "MPSearchCaseViewController.h"
#import "ESIMSessionListViewController.h"

#import "SHVersionTool.h"
#import "ESAppConfigManager.h"

#import "EZHome-Swift.h"

@implementation ESMainURLServices

+ (void)registerESMainURLServices {
    /**---------------------------子组件的URLServices注册--------------------------**/
    [ESFoundationURLServices registerESFoundationURLServices];
    [ESMallURLServices registerESMallURLServices];
    /**---------------------------商城相关--------------------------**/
    //商城首页
    [MGJRouter registerURLPattern:@"/Mall/MallHome" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------商城首页----------\n%@\n-------------------", routerParameters);
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [[CoTabBarControllerManager tabBarManager] setCurrentController:3];
            [nav popToRootViewControllerAnimated:YES];
        }
    }];
    
    //选择优惠券
    [MGJRouter registerURLPattern:@"/Mall/ChooseCoupons" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------选择优惠券---------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        ESChooseCouponsViewController *vc = [[ESChooseCouponsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        NSString *subOrderId = [info objectForKey:@"subOrderId"];
        NSString *orderId = [info objectForKey:@"pendingOrderId"];
        NSMutableDictionary *couponDic = [[info objectForKey:@"couponDict"] mutableCopy];
        [vc setSubOrderId:subOrderId orderId:orderId CouponInfo:couponDic block:routerParameters[MGJRouterParameterCompletion]];
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    
    
    
    /**---------------------------个人中心相关--------------------------**/
    //登录
    [MGJRouter registerURLPattern:@"/UserCenter/LogIn" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------登录----------\n%@\n-------------------", routerParameters);
        if ([ESLoginManager sharedManager].isLogin) {
            return ;
        } else {
            SHRNViewController *loginController = [[SHRNViewController alloc] init];
            ESNavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:loginController];
            [nav.viewControllers.lastObject presentViewController:navVC animated:YES completion:nil];
        }
    
    }];
    
    //我的装修基金
    [MGJRouter registerURLPattern:@"/UserCenter/MyGold" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------我的装修基金----------\n%@\n-------------------", routerParameters);
        if ([ESLoginManager sharedManager].isLogin) {
            ESMyGoldViewController *myGoldViewCon = [[ESMyGoldViewController alloc]init];
            myGoldViewCon.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:myGoldViewCon animated:YES];
        } else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
        
    }];
    
    //我的优惠券
    [MGJRouter registerURLPattern:@"/UserCenter/MyCoupons" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------我的优惠券----------\n%@\n-------------------", routerParameters);
        if ([ESLoginManager sharedManager].isLogin) {
            ESMyCouponsViewController *myCouponsViewCon = [[ESMyCouponsViewController alloc]init];
            myCouponsViewCon.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:myCouponsViewCon animated:YES];
        } else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
        
    }];
    
    
    /**---------------------------设计相关--------------------------**/
    //案例详情
    [MGJRouter registerURLPattern:@"/Design/Example" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------案例详情---------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *caseid = info[@"caseid"]?info[@"caseid"]:@"";
        NSString *isnew = info[@"isnew"]?info[@"isnew"]:@"0";
        NSString *type = info[@"type"]?info[@"type"]:@"0";
        NSString *source = info[@"source"] ?: @"1";
        
        if ([isnew isEqualToString:@"1"]) {
            CaseStyleType styleType = CaseStyleType2D;
            if ([type isEqualToString:@"1"]) {
                styleType = CaseStyleType3D;
            }
            
            CaseSourceType sourceType = CaseSourceTypeBySearch;
            if ([source isEqualToString:@"2"]) {
                sourceType = CaseSourceTypeBy3D;
            }
            
            
            
            
            ESCaseDetailViewController *caseDetailVC = [[ESCaseDetailViewController alloc] init];
            [caseDetailVC setCaseId:caseid caseStyle:styleType caseSource:sourceType caseCategory:CaseCategoryNormal];
            caseDetailVC.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:caseDetailVC animated:YES];
        } else {
            CoCaseDetailController *caseDetailVC = [[CoCaseDetailController alloc] initWithCaseID:caseid];
            caseDetailVC.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:caseDetailVC animated:YES];
        }
    }];
    
    //设计师详情
    [MGJRouter registerURLPattern:@"/Design/DesignerDetail" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------设计师详情---------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *designId = info[@"designId"]?info[@"designId"]:@"";
        
        ESDesignerDetailViewController *detail = [[ESDesignerDetailViewController alloc] init];
        detail.designId = designId;
        detail.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:detail animated:YES];
        
    }];
    
    //消费者设计详情
    [MGJRouter registerURLPattern:@"/Design/DesignDetail" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------设计详情---------\n%@\n-------------------", routerParameters);
        if (![ESLoginManager sharedManager].isLogin) {
            SHRNViewController *loginController = [[SHRNViewController alloc] init];
            ESNavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [nav.viewControllers.lastObject presentViewController:loginController animated:YES completion:nil];
            return;
        }
        
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *designid = @"";
        if (info && [info objectForKey:@"designid"]) {
            designid = [NSString stringWithFormat:@"%@", info[@"designid"]];
        }
        
        if ([designid length] <= 0) {
            return;
        }
        
        UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
        [ESPackageManager openProProjectDetalWithAssetId: designid navigationController: nav];
    }];
    
    
    //套餐首页
    [MGJRouter registerURLPattern:@"/Design/PackageHome" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------套餐首页---------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *isFromHome = info[@"isFromHome"]?info[@"isFromHome"]:@"";
        
//        CoPackageViewController *coPackageViewCon = [[CoPackageViewController alloc]init];
//        if ([isFromHome isEqualToString:@"YES"]) {
//            coPackageViewCon.isFromHome = YES;
//        }
//        coPackageViewCon.hidesBottomBarWhenPushed = YES;
//        [[ESPublicMethods getCurrentNavigationController] pushViewController:coPackageViewCon animated:YES];
        
    }];
    
    //套餐样板间列表
    [MGJRouter registerURLPattern:@"/Design/PackageHomeList" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------套餐样板间列表---------\n%@\n-------------------", routerParameters);
        ESModelListViewController *vc = [[ESModelListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    
    //我要装修
    [MGJRouter registerURLPattern:@"/Design/Decoration" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------套餐首页---------\n%@\n-------------------", routerParameters);
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [[CoTabBarControllerManager tabBarManager] setCurrentController:2];
            [[CoTabBarControllerManager tabBarManager] changeTabBarSelectedIndex:2];
            [[CoTabBarControllerManager tabBarManager].tabBarController.tabBar setHidden:YES];
            [nav popToRootViewControllerAnimated:YES];
        }
    }];
    
    //创建北舒套餐
    [MGJRouter registerURLPattern:@"/Design/CreatePackage" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------创建北舒套餐---------\n%@\n-------------------", routerParameters);
        NSDictionary *createDic = routerParameters[MGJRouterParameterUserInfo];
        
        ESCreateProjectViewController *northVC = [[ESCreateProjectViewController alloc]init];
        [northVC setConsumerInfo:createDic];
        
        [[ESPublicMethods getCurrentNavigationController] pushViewController:northVC animated:YES];
        
    }];
    
    //套餐免费预约
    [MGJRouter registerURLPattern:@"Design/FreeAppoint" toHandler:^(NSDictionary *routerParameters) {
        
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *type = info[@"type"]?info[@"type"]:@"";
        
        ESAppointTableVC *VC = [[UIStoryboard storyboardWithName:@"ESAppointVC" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointVC"];//[[ESAppointTableVC alloc]init];

        VC.pkgType = type.intValue;
        VC.selectedType = 5;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:VC animated:YES];
        
    }];
    
    //创建施工项目
    [MGJRouter registerURLPattern:@"/Design/CreateConstruction" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------创建北舒套餐---------\n%@\n-------------------", routerParameters);
        NSDictionary *createDic = routerParameters[MGJRouterParameterUserInfo];
        ESCreateEnterpriseViewController *vc = [[ESCreateEnterpriseViewController alloc] initWithMemberinfo:createDic];
        vc.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    
    
    //获取app config
    [MGJRouter registerURLPattern:@"/App/GetAppConfig" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------获取App Config---------\n%@\n-------------------", routerParameters);
        ESAppConfig *config = [ESAppConfigManager sharedManager].appConfig;
        NSDictionary *result = [ESAppConfig dictFromObj:config];
        void (^completion)(NSDictionary *dict) = routerParameters[MGJRouterParameterCompletion];
        if (completion) {
            completion(result);
        }
    }];
    
    //打开Web H5
    [MGJRouter registerURLPattern:@"/App/OpenWebView" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------打开Web H5---------\n%@\n-------------------", routerParameters);
        NSDictionary *dict = routerParameters[MGJRouterParameterUserInfo];
        NSString *title = [dict objectForKey:@"title"];
        NSString *url = [dict objectForKey:@"url"];
        ESWebViewController *webViewVC = [[ESWebViewController alloc] initWithTitle:title
                                                                                url:url];
        [[ESPublicMethods getCurrentNavigationController] pushViewController:webViewVC animated:YES];
        
    }];
    
    //IM 与厂商聊天
    [MGJRouter registerURLPattern:@"/NIM/ByDealerId" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"----------打开Web H5---------\n%@\n-------------------", routerParameters);
        NSDictionary *dict = routerParameters[MGJRouterParameterUserInfo];
        NSString *dealerId = [dict objectForKey:@"id"];
        UIViewController *vc = [dict objectForKey:@"viewController"];

        ESIMSource imSource = ESIMSourceNone;
        NSString *source = [dict objectForKey:@"source"];
        if (source) {
            if ([source isEqualToString:@"productDetail"]) {
                imSource = ESIMSourceProductDetail;
            }else if ([source isEqualToString:@"projectDetail"]) {
                imSource = ESIMSourceProjectDetail;
            }else if ([source isEqualToString:@"designerHome"]) {
                imSource = ESIMSourceDesignerHome;
            }else if ([source isEqualToString:@"caseDetail"]) {
                imSource = ESIMSourceCaseDetail;
            }
        }
        [ESNIMManager startP2PSessionFromVc:vc withDealerId:dealerId andSource:imSource];
    }];
    
    //账号设置
//    [MGJRouter registerURLPattern:@"/Person/AccountSetting" toHandler:^(NSDictionary *routerParameters) {
//        SHLog(@"---------账号设置----------\n%@\n-------------------", routerParameters);
//        SHRNViewController *accountSettingVC = [[SHRNViewController alloc]
//                                                initWithReactNativeType:SHReactNativeModuleAddPhone
//                                                params:@{@"phone":[JRKeychain loadSingleUserInfo:UserInfoCodePhone]}];
//        
//        accountSettingVC.hidesBottomBarWhenPushed = YES;
//        [[ESPublicMethods getCurrentNavigationController] pushViewController:accountSettingVC animated:YES];
//    }];
    
    //家装试衣间详情
    [MGJRouter registerURLPattern:@"/Case/CaseDetail/FittingRoom" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------家装试衣间详情----------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *brandId = info[@"brandId"]?info[@"brandId"]:@"";
        NSString *caseId = info[@"caseId"]?info[@"caseId"]:@"";
        NSString *caseType = info[@"caseType"] ? info[@"caseType"] : @"";
        
        CaseStyleType type = CaseStyleType3D;
        if ([caseType isEqualToString:@"2d"]) {
            type = CaseStyleType2D;
        }
        
        ESCaseDetailViewController *caseDetailVC = [[ESCaseDetailViewController alloc] init];
        caseDetailVC.brandId = brandId;
        caseDetailVC.hidesBottomBarWhenPushed = YES;
        [caseDetailVC setCaseId:caseId caseStyle:type caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryFitting];
         [[ESPublicMethods getCurrentNavigationController] pushViewController:caseDetailVC animated:YES];
    }];
    
    //套餐样板间详情
    [MGJRouter registerURLPattern:@"/Case/CaseDetail/PackageRoom" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------套餐样板间详情----------\n%@\n-------------------", routerParameters);
        NSDictionary *info = routerParameters[MGJRouterParameterUserInfo];
        NSString *brandId = info[@"brandId"]?info[@"brandId"]:@"";
        NSString *caseId = info[@"caseId"]?info[@"caseId"]:@"";
        NSString *caseType = info[@"caseType"] ? info[@"caseType"] : @"";

        CaseStyleType type = CaseStyleType3D;
        if ([caseType isEqualToString:@"2d"]) {
            type = CaseStyleType2D;
        }
        
        ESCaseDetailViewController *caseDetailVC = [[ESCaseDetailViewController alloc] init];
        caseDetailVC.brandId = brandId;
        caseDetailVC.hidesBottomBarWhenPushed = YES;
        [caseDetailVC setCaseId:caseId caseStyle:type caseSource:CaseSourceTypeBySearch caseCategory:CaseCategoryPackage];
        [[ESPublicMethods getCurrentNavigationController] pushViewController:caseDetailVC animated:YES];
    }];
    
    //判断金融是否隐藏
    [MGJRouter registerURLPattern:@"hiddenFinance" toHandler:^(NSDictionary *routerParameters) {
        BOOL isHiddenFinance = NO;//[SHVersionTool checkVersionCode:[ESAppConfigManager sharedManager].appConfig.consumerVersionFinance];
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^completion)(NSString *) = routerParameters[MGJRouterParameterCompletion];
            if (completion) {
                completion([NSString stringWithFormat:@"%d", isHiddenFinance]);
            }
        });
    }];
    
    //判断金融打包环境
    [MGJRouter registerURLPattern:@"isReleaseModel" toHandler:^(NSDictionary *routerParameters) {
        BOOL CurrentIsProduct = [[JRNetEnvConfig sharedInstance].netEnvModel.envFlag isEqualToString:@""];
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^completion)(NSString *) = routerParameters[MGJRouterParameterCompletion];
            if (completion) {
                completion([NSString stringWithFormat:@"%d", CurrentIsProduct]);
            }
        });
    }];
    
    //设计家首页
    [MGJRouter registerURLPattern:@"/Shejijia/Home" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------设计家首页----------\n%@\n-------------------", routerParameters);
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [[CoTabBarControllerManager tabBarManager] setCurrentController:0];
            [nav popToRootViewControllerAnimated:YES];
        }
    }];
    
    //套餐项目列表
    [MGJRouter registerURLPattern:@"/Shejijia/PkgProject/List" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------设计家首页----------\n%@\n-------------------", routerParameters);
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            ESProProjectListController *vc = [ESPackageManager refreshProProjectList:nav];
            if (vc != nil) {
                [nav popToViewController:vc animated:true];
            }
        }
    }];
    
    //套餐项目详情
    [MGJRouter registerURLPattern:@"/Shejijia/PkgProject/Detail" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------设计家首页----------\n%@\n-------------------", routerParameters);
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            ESProProjectDetailContoller *vc = [ESPackageManager refreshProProjectDetail:nav];
            if (vc != nil) {
                [nav popToViewController:vc animated:true];
            }
        }
    }];
    //家装试衣间列表
    [MGJRouter registerURLPattern:@"/Case/List/FittingRoom" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------家装试衣间列表----------\n%@\n-------------------", routerParameters);
        ESCaseFittingRoomHomeViewController *vc = [[ESCaseFittingRoomHomeViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.needBackBtn = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    //案例列表
    [MGJRouter registerURLPattern:@"/Case/List/CaseList" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------案例列表----------\n%@\n-------------------", routerParameters);
        CoHomeBaseViewController *example = [[CoHomeBaseViewController alloc] init];
        example.isFromHome = YES;
        example.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:example animated:YES];
    }];
    //设计师列表
    [MGJRouter registerURLPattern:@"/Designer/List/DesignerList" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------设计师列表----------\n%@\n-------------------", routerParameters);
        MPFindDesignersViewController *designers = [[MPFindDesignersViewController alloc] init];
        designers.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:designers animated:YES];
    }];
    //个人中心
    [MGJRouter registerURLPattern:@"/My/Mine_Home" toHandler:^(NSDictionary *routerParameters) {
        SHLog(@"---------个人中心----------\n%@\n-------------------", routerParameters);
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UINavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [[CoTabBarControllerManager tabBarManager] setCurrentController:4];
            [nav popToRootViewControllerAnimated:YES];
        }
    }];
    // 向下拉刷新的头中传递文字
    [MGJRouter registerURLPattern:@"refresh/Header/TipMessage" toHandler:^(NSDictionary *routerParameters) {
        dispatch_async_get_main_safe(^{
            void (^completion)(NSArray *) = routerParameters[MGJRouterParameterCompletion];
            if (completion)
            {
                completion([ESAppConfigManager sharedManager].refreshTips);
            }
        });
    }];
    // 五金涂料
    [MGJRouter registerURLPattern:@"market/Hardware" toHandler:^(NSDictionary *routerParameters) {
        ESLiWuMarketController *vc = [[ESLiWuMarketController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:vc animated:YES];
    }];
    
    /// 案例搜索
    [MGJRouter registerURLPattern:@"/Case/Search" toHandler:^(NSDictionary *routerParameters) {
        MPSearchCaseViewController *searchVC = [[MPSearchCaseViewController alloc] init];
        searchVC.searchType = @"3D";
        searchVC.hidesBottomBarWhenPushed = YES;
        [[ESPublicMethods getCurrentNavigationController] pushViewController:searchVC animated:YES];
    }];
    
    [MGJRouter registerURLPattern:@"/IM/ChatList" toHandler:^(NSDictionary *routerParameters) {
        if ([ESLoginManager sharedManager].isLogin) {
            ESIMSessionListViewController *sessionListVc = [[ESIMSessionListViewController alloc] init];
            sessionListVc.hidesBottomBarWhenPushed = YES;
            [[ESPublicMethods getCurrentNavigationController] pushViewController:sessionListVc animated:YES];
        } else {
            [MGJRouter openURL:@"/UserCenter/LogIn"];
        }
    }];
    
    /// 居然金融环境配置
}

@end
