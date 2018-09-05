//
//  ESPersonalCenterController.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/21.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESPersonalCenterController.h"
#import "CoPersonalCenterModel.h"
#import "SHLoginTool.h"
#import "ESPersonalCenterConfig.h"
#import "ESPersonalCenterView.h"
#import "CoMyFocusController.h"
#import "MPmoreViewController.h"
#import "JRConsumerQRCodeReader.h"
#import "SHQRCodeTool.h"
#import "ESAddressManagementController.h"
#import "ESMyOrderViewController.h"
#import "ESShoppingCartController.h"
#import "ESQRCodeView.h"
#import "JRWebViewController.h"
#import "JRKeychain.h"
#import "HtmlURL.h"
#import "ESCreateEnterpriseViewController.h"
#import "ESMyCommentViewController.h"
#import "ESConstructListViewController.h"
#import "ESMyCouponsViewController.h"
#import "ESMyGoldViewController.h"
#import <ESFoundation/UMengServices.h>
#import "ESMemberInfoController.h"
#import "ESDesignerInfoController.h"
#import <ESNetworking/SHAlertView.h>
#import "ESMyMessageViewController.h"
#import "MBProgressHUD+NJ.h"
#import "ESRecommendViewController.h"
#import "ESRecommendOrderViewController.h"
#import "ESCooperativeBrandListViewController.h"
#import "ESRecommendFromDesingerController.h"

#import "ESFinanceServices.h"
#import "EZHome-Swift.h"
#import "SHVersionTool.h"
#import "ESAppConfigManager.h"

#define MAIN_VIEW_TAG 901

@interface ESPersonalCenterController ()<ESPersonalCenterViewDelegate>
@property (nonatomic, strong) CoPersonalCenterModel *dataModel;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSDictionary *> *> *memberItems;
@end

@implementation ESPersonalCenterController
{
    CGFloat _tableViewY;
}

#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMainView];
    [self initNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDataFromNet];
    [self updateItemsData];
}

#pragma mark - 初始化
/**
 *  初始化导航栏
 */
- (void)initNavigationItem {
    [self.view bringSubviewToFront:self.navgationImageview];
    self.navgationImageview.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.mainContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.navigationBarBottomLine.hidden = YES;
    [self.leftButton setImage:[UIImage imageNamed:@"personal_set"] forState:UIControlStateNormal];
    
    //TODO 待新的消息中心
    [self.rightButton setImage:[UIImage imageNamed:@"nav_message"] forState:UIControlStateNormal];
//    self.rightButton.hidden = YES;
}

- (void)initMainView {
    CGFloat contentH = SCREEN_HEIGHT - TABBAR_HEIGHT;
    ESPersonalCenterView *mainView = [[ESPersonalCenterView alloc] initWithFrame: CGRectMake(0, -20, SCREEN_WIDTH, contentH + 20)];
    mainView.tag = MAIN_VIEW_TAG;
    mainView.delegate = self;
    [mainView setDelegate];
    [self.view addSubview: mainView];
}

/**
 * Item数据
 */
- (void)updateItemsData {
    BOOL hiddenFinance = NO;//[SHVersionTool checkVersionCode:[ESAppConfigManager sharedManager].appConfig.consumerVersionFinance];
    BOOL hasRecommend = self.dataModel.canRecommend;
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        self.memberItems = [NSMutableArray arrayWithArray:[ESPersonalCenterConfig getDesignerItemsWithHiddenFinance:hiddenFinance hasRecommend:hasRecommend]];
    }else {
        self.memberItems = [NSMutableArray arrayWithArray:[ESPersonalCenterConfig getConsumerItemsWithHiddenFinance:hiddenFinance]];
    }
}

#pragma mark - 获取数据
/**
 *  获取网络数据
 */
- (void)getDataFromNet {
    
    if (![ESLoginManager sharedManager].isLogin) {
        return;
    }
    WS(weakSelf);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [CoPersonalCenterModel getMemberInfoWithSuccess:^(CoPersonalCenterModel *model) {
        [SHLoginTool saveLoginAvatar:model.headIconLink account:model.mobile_number];
        weakSelf.dataModel = model;
        [weakSelf updateItemsData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateMainView];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    } andUnreadCount:^(NSInteger count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setUnreadViewHidden: count <= 0];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    } andFailure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//        if ([SHAppGlobal isHaveNetwork]) {
//            [SHAlertView showAlertForNetError];
//        }
    }];
}

#pragma mark - 刷新UI
/**
 *  设置未读view是否隐藏
 *  @param hidden
 */
- (void)setUnreadViewHidden:(BOOL) hidden {
    [self.msgCenterUnReadView setHidden:hidden];
}

/**
 *  更新MainView
 */
- (void)updateMainView {
    ESPersonalCenterView *mainView = [self.view viewWithTag:MAIN_VIEW_TAG];
    if (mainView) {
        [mainView refreshMainView];
    }
}

#pragma mark - 跳转
/**
 *  进入 "消息中心"
 */
- (void)goToMessageCenter {
    
    [UMengServices eventWithEventId:Event_mine_news];

    if (![ESLoginManager sharedManager].isLogin){
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    } else {
        ESMyMessageViewController *vc = [[ESMyMessageViewController alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 *  进入 推荐清单
 */
- (void)tapRecommendList {
    SHLog(@"推荐清单");
    ESRecommendViewController *recommendViewCon = [[ESRecommendViewController alloc] init];
    recommendViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommendViewCon animated:YES];
}

/**
 *  进入 客户订单
 */
- (void)tapCustomerOrderList {
    SHLog(@"客户订单");
    ESRecommendOrderViewController *recommendOrderListViewCon = [[ESRecommendOrderViewController alloc] init];
    recommendOrderListViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommendOrderListViewCon animated:YES];
}

- (void)tapCooperativeBrand {
    SHLog(@"合作品牌");
    ESCooperativeBrandListViewController *cooperativeBrandListViewCon = [[ESCooperativeBrandListViewController alloc] init];
    cooperativeBrandListViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cooperativeBrandListViewCon animated:YES];
}

/**
 *  进入 我的钱包
 */
- (void)tapWallet {
    SHLog(@"我的钱包");
    NSMutableDictionary *pluginDict = [NSMutableDictionary dictionary];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", self.dataModel.prodId] forKey:@"prodId"];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", self.dataModel.status] forKey:@"status"];
    [pluginDict setObject:@"QBTZ" forKey:@"entrance"];
//    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
//    if ([appType isEqualToString:@"MALL"]) {
//        [pluginDict setObject:@"mall" forKey:@"appType"];
//    } else if ([appType isEqualToString:@"CONSUMER"]) {
//        [pluginDict setObject:@"proprietor" forKey:@"appType"];
//    } else {
//        [pluginDict setObject:@"designer" forKey:@"appType"];
//    }
    
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        [pluginDict setObject:@"designer" forKey:@"appType"];
    }else {
        [pluginDict setObject:@"proprietor" forKey:@"appType"];
    }
    [[ESFinanceServices sharedInstance] jumpToFinanceViewcontrollerWithInfo:pluginDict block:^(NSDictionary *resultDic) {
        SHLog(@"%@", resultDic);
        NSString *suc = [NSString stringWithFormat:@"%@", resultDic[@"errCode"]?resultDic[@"errCode"]:@""];
        if ([suc isEqualToString:@"000000"]) {
        } else {
            NSString *errmsg = [NSString stringWithFormat:@"%@", resultDic[@"errMsg"]?resultDic[@"errMsg"]:@""];
            [MBProgressHUD showError:errmsg];
        }
    }];
    
}
/**
 *  进入 居然分期
 */
- (void)tapFinance {
    SHLog(@"居然分期");
    
    NSMutableDictionary *pluginDict = [NSMutableDictionary dictionary];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", self.dataModel.prodId] forKey:@"prodId"];
    [pluginDict setObject:[NSString stringWithFormat:@"%@", self.dataModel.status] forKey:@"status"];
    [pluginDict setObject:@"EDTZ" forKey:@"entrance"];
//    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
//    if ([appType isEqualToString:@"MALL"]) {
//        [pluginDict setObject:@"mall" forKey:@"appType"];
//    } else if ([appType isEqualToString:@"CONSUMER"]) {
//        [pluginDict setObject:@"proprietor" forKey:@"appType"];
//    } else {
//        [pluginDict setObject:@"designer" forKey:@"appType"];
//    }
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        [pluginDict setObject:@"designer" forKey:@"appType"];
    }else {
        [pluginDict setObject:@"proprietor" forKey:@"appType"];
    }
    [[ESFinanceServices sharedInstance] jumpToFinanceViewcontrollerWithInfo:pluginDict block:^(NSDictionary *resultDic) {
        SHLog(@"%@", resultDic);
        NSString *suc = [NSString stringWithFormat:@"%@", resultDic[@"errCode"]?resultDic[@"errCode"]:@""];
        if ([suc isEqualToString:@"000000"]) {
        } else {
            NSString *errmsg = [NSString stringWithFormat:@"%@", resultDic[@"errMsg"]?resultDic[@"errMsg"]:@""];
            [MBProgressHUD showError:errmsg];
        }
    }];
}

/**
 *  进入 消费者 "我的项目"
 */
- (void)tapMyProject {
    
    [UMengServices eventWithEventId:Event_mine_project];
    
    ESProProjectListController *vc = [[ESProProjectListController alloc] init];
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "我的订单"
 */
- (void)tapMyOrder {
    ///我的订单埋点统计
    [UMengServices eventWithEventId:Event_my_order];
    ESMyOrderViewController *myOrderViewCon = [[ESMyOrderViewController alloc]init];
    myOrderViewCon.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myOrderViewCon animated:YES];
}

/**
 *  进入 "我的购物车"
 */
- (void)tapShoppingCart {
    ///我的购物车埋点统计
    [UMengServices eventWithEventId:Event_my_shopcar];
    ESShoppingCartController *vc = [[ESShoppingCartController alloc] init];
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "收货地址管理"
 */
- (void)tapShoppingAddress {
    ///我的收货地址埋点统计
    [UMengServices eventWithEventId:Event_my_address];
    ESAddressManagementController *vc = [[ESAddressManagementController alloc] init];
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "设计师推荐"
 */
- (void)tapDesingerRecommend {
    
    [UMengServices eventWithEventId:Event_mine_designers_recommend];
    ESRecommendFromDesingerController *vc = [[ESRecommendFromDesingerController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  进入 "我关注的设计师"
 */
- (void)tapMyAttention {
    
    [UMengServices eventWithEventId:Event_mine_concerned_designers];
    CoMyFocusController *vc = [[CoMyFocusController alloc] init];
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "我的评价"
 */
- (void)tapMyCommit {
    ESMyCommentViewController *vc = [[ESMyCommentViewController alloc] init];
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "更多"
 */
- (void)tapMore {
    MPmoreViewController *vc = [[MPmoreViewController alloc] init];
    vc.phoneNumber=self.dataModel.mobile_number;
    [self customPushViewController:vc animated:YES];
}

/**
 *  进入 "创建北舒套餐"
 */
- (void)tapBeishu {
    
    [UMengServices eventWithEventId:Event_mine_create_beishu];
    JRConsumerQRCodeReader *redader = [[JRConsumerQRCodeReader alloc] init];
    redader.type = QRReaderTypePackage;
    WS(weakSelf);
    redader.dict = ^(NSDictionary *dict){
        
        if ([dict allKeys].count == 5) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ESCreateProjectViewController *vc = [[ESCreateProjectViewController alloc]init];
                [vc setConsumerInfo:dict];
                
//                MPNorthComfortPackageViewController *vc =[[MPNorthComfortPackageViewController alloc] init];
//                vc.consumerInformationDict = dict;
                [weakSelf customPushViewController:vc animated:NO];//
            });
            
        } else {
            [SHAlertView showAlertWithMessage:@"无法识别此二维码" sureKey:^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    };
    
    if ([SHQRCodeTool checkCameraEnable]) {
        [self customPushViewController:redader animated:YES];
    }
    return;

}

/**
 *  进入 "我的主页"
 */
- (void)tapHomePage {
    
    [UMengServices eventWithEventId:Event_mine_homepage];
    if ([ESLoginManager sharedManager].isLogin) {
        NSString *designerId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:designerId forKey:@"designId"];
        [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:dict completion:nil];

    } else {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    }
}
#pragma mark - Override

- (void)tapOnRightButton:(id)sender {
    [self goToMessageCenter];
}

- (void)tapOnLeftButton:(id)sender {
    [self tapMore];
}

#pragma mark - ESPersonalCenterViewDelegate

- (NSInteger)getSectionNums {
    if (self.memberItems) {
        return self.memberItems.count;
    }
    return 0;
}

- (NSInteger)getItemNums:(NSInteger)section {
    if (self.memberItems) {
        if ([self userIsDesigner] && section == 0) {
            return 1;
        }
        NSArray *items = [self.memberItems objectAtIndex:section];
        if (items) {
            return items.count;
        }
    }
    return 0;
}

- (void)tapItemWithIndex:(NSInteger)index andSection:(NSInteger)section {
    
    if (![ESLoginManager sharedManager].isLogin) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    
    if (self.memberItems) {
        NSArray *items = [self.memberItems objectAtIndex:section];
        if (items) {
            NSDictionary *item = [items objectAtIndex:index];
            if (item && [item objectForKey:@"action"]) {
                NSString *actionName = [item objectForKey:@"action"];
                SEL action = NSSelectorFromString(actionName);
                if ([self respondsToSelector:action]) {
                    IMP imp = [self methodForSelector:action];
                    void (*func)(id, SEL) = (void *)imp;
                    func(self, action);
                }
            }
        }
    }
}

- (void)tableViewDidScrollWithContentY:(CGFloat)contentY
{
    if (_tableViewY <= 0)
    {
        _tableViewY = contentY;
    }

    CGFloat component = 0.0f;
    if (contentY - _tableViewY <= NAVBAR_HEIGHT)
    {
        component = (contentY - _tableViewY)/(NAVBAR_HEIGHT * 1.0);
    }
    else
    {
        component = 1.0f;
    }

    self.navgationImageview.backgroundColor = [[UIColor stec_viewBackgroundColor] colorWithAlphaComponent:component];
    self.mainContainer.backgroundColor = [[UIColor stec_viewBackgroundColor] colorWithAlphaComponent:component];
}

#pragma mark - ESPersonalHeaderViewDelegate
- (BOOL)userIsDesigner {
    return [SHAppGlobal AppGlobal_GetIsDesignerMode];
}

- (NSString *)getUserHeadIcon {
    if (self.dataModel && self.dataModel.headIconLink && ![self.dataModel.headIconLink isEqualToString:@""]) {
        return self.dataModel.headIconLink;
    }
    return @"";
}

- (NSString *)getUserName {
    if (self.dataModel && self.dataModel.userName && ![self.dataModel.userName isEqualToString:@""]) {
        return self.dataModel.userName;
    }
    return @"暂无数据";
}

- (void)tapUserHeadIcon {
    
    [UMengServices eventWithEventId:Event_mine_avatar];
    if (![ESLoginManager sharedManager].isLogin) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        ESDesignerInfoController *vc = [[ESDesignerInfoController alloc] init];
        [self customPushViewController:vc animated:YES];
    }else {
        ESMemberInfoController *vc = [[ESMemberInfoController alloc] init];
        [self customPushViewController:vc animated:YES];
    }
}

- (void)tapRightButton {
    if (![ESLoginManager sharedManager].isLogin) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    
    if ([self userIsDesigner]) {
        [self tapHomePage];
    }else {
        [ESQRCodeView showInView];
    }
}

#pragma mark - ESPersonalActiveCellDelegate

- (NSString *)getCouponNumber {
    if (self.dataModel) {
        return self.dataModel.couponsAmount?self.dataModel.couponsAmount:@"0";
    }
    return @"0";
}

- (NSString *)getGoldNumber {
    if (self.dataModel) {
        return self.dataModel.pointAmount?self.dataModel.pointAmount:@"0";
    }
    return @"0";
}

- (void)isSelectCoupon:(BOOL)isSelectCoupon {
    if (isSelectCoupon) {
        SHLog(@"优惠券");
        ESMyCouponsViewController *myCouponsViewCon = [[ESMyCouponsViewController alloc] init];
        myCouponsViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myCouponsViewCon animated:YES];
    } else {
        SHLog(@"金币");
        ESMyGoldViewController *myGoldViewCon = [[ESMyGoldViewController alloc] init];
        myGoldViewCon.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myGoldViewCon animated:YES];
    }
}


#pragma mark - ESPersonalCenterCellDelegate
- (NSString *)getItemIconWithIndexPath:(NSIndexPath *)indexPath {
    if (self.memberItems) {
        NSArray *items = [self.memberItems objectAtIndex:indexPath.section];
        if (items) {
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            if (item && [item objectForKey:@"icon"]) {
                return [item objectForKey:@"icon"];
            }
        }
    }
    return @"";
}

- (NSString *)getItemTitleWithIndexPath:(NSIndexPath *)indexPath {
    if (self.memberItems) {
        NSArray *items = [self.memberItems objectAtIndex:indexPath.section];
        if (items) {
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            if (item && [item objectForKey:@"title"]) {
                return [item objectForKey:@"title"];
            }
        }
    }
    return @"";
}

- (NSString *)getMoneyNumber {
    if (self.dataModel) {
        return [NSString stringWithFormat:@"账户余额 ￥%@", self.dataModel.ablAmt?self.dataModel.ablAmt:@"0.00"];
    }
    return @"账户余额 ￥0.00";
}

- (NSString *)getFinanceNumber {
    if (self.dataModel) {
        if(self.dataModel.validLimit && (![self.dataModel.validLimit isEqualToString:@""])) {
            return self.dataModel.statusInfo?self.dataModel.statusInfo:@"";
        } else {
            if ([self.dataModel.status isEqualToString:@"SQZT_JH"]) {
                return self.dataModel.statusInfo?self.dataModel.statusInfo:@"";
            } else {
                return self.dataModel.statusName?self.dataModel.statusName:@"";
            }
        }
        
    }
    return @"";
}

- (NSString *)getFinanceStatus {
    if (self.dataModel) {
        return self.dataModel.status?self.dataModel.status:@"";
    }
    return @"";
}

#pragma mark - ESPersonalDesignerFirstCellDelegate
/**
 设计师我的项目
 */
- (void)tapDesignerMyProject {
    
    [UMengServices eventWithEventId:Event_mine_project];
    if (![ESLoginManager sharedManager].isLogin) {
        [MGJRouter openURL:@"/UserCenter/LogIn"];
        return;
    }
    
    ESDesProjectMainController *vc = [[ESDesProjectMainController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 设计师创建施工项目
 */
- (void)tapEnterprise {
    SHLog(@"创建施工项目");
    JRConsumerQRCodeReader *reader = [[JRConsumerQRCodeReader alloc] init];
    reader.type = QRReaderTypeEnterprise;
    WS(weakSelf);
    reader.dict = ^(NSDictionary *dict){
        
        if ([dict allKeys].count == 5) {
            
            dispatch_async_get_main_safe(^{
                ESCreateEnterpriseViewController *vc = [[ESCreateEnterpriseViewController alloc] initWithMemberinfo:[dict copy]];
                vc.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            })
            
        } else {
            [SHAlertView showAlertWithMessage:@"无法识别此二维码" sureKey:^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
    };
    
    
    if ([SHQRCodeTool checkCameraEnable]) {
        [self customPushViewController:reader animated:YES];
    }
}

/**
 设计师我的施工项目列表
 */
- (void)tapDesignerMyEnterpriseProject {
    
    [UMengServices eventWithEventId:Event_mine_construction_project];
    SHLog(@"设计师我的施工项目列表");
    ESConstructListViewController *vc = [[ESConstructListViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Other Method
- (void)pushToMyProjectList {
    [self tapMyProject];
}

@end
