//
//  Assistant.m
//  Consumer
//
//  Created by jiang on 2017/5/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "Assistant.h"
#import "DefaultSetting.h"
#import "JRWebViewController.h"
#import "JRKeychain.h"
#import "JRNetEnvConfig.h"
#import "ESShareView.h"
#import "MBProgressHUD+NJ.h"
#import <MGJRouter/MGJRouter.h>

@implementation Assistant
/*------------------资源位--------------*/
//http://10.199.39.25:8090/pages/viewpage.action?pageId=6063157
typedef NS_ENUM(NSInteger, ShowCaseOperationType)//
{
    NONE, // NONE
    H5, //H5
    PACKAGE_HOME, //套餐首页
    DECORATION, //我要装修
    DESIGNER_DATAIL, //设计师详情
    EXAMPLE_DATAIL, //案例详情
    CALL, //打电话
    BACK, //返回上一页
    CREAT_PACKAGE, //创建北舒套餐
    GOOD_DETAIL, //商品详情
    MASTERIAL_HOME, //商城首页
    DESIGN_DATAIL,//设计详情
    BACK_ROOT, //返回首页
    LOGIN, //登录,
    GET_TOKEN,//获取TOKEN
    CREAT_PROMOTION, //创建施工项目
    COUPONS,//优惠券
    GOLD,//金币
    GOOD_KILL,//秒杀商品详情
    MARKET_CATEGORY,//丽屋超市品类列表
    SHARE,//分享
    COMBO_ROOM,
    TO_RESERVATION,//套餐免费预约
    DESIGN_DETAIL,//设计详情(首页)
    FITTING_ROOM, //家装试衣间
    CASE_LIST,//案例列表
    DESIGNER_LIST,//设计师列表
    MINE_HOME,//个人中心
    H5_BBS,// 论坛相关的h5页面
    MARKET_HARDWARE,//五金涂料
};

+ (ShowCaseOperationType)typeOfOperationType:(NSString *)operationType {
    NSArray *typeArray = [NSArray arrayWithObjects:
                          @"NONE",
                          @"H5",
                          @"PACKAGE_HOME",
                          @"DECORATION",
                          @"DESIGNER_DATAIL",
                          @"EXAMPLE_DATAIL",
                          @"CALL",
                          @"BACK",
                          @"CREAT_PACKAGE",
                          @"GOOD_DETAIL",
                          @"MASTERIAL_HOME",
                          @"DESIGN_DATAIL",
                          @"BACK_ROOT",
                          @"LOGIN",
                          @"GET_TOKEN",
                          @"CREAT_PROMOTION",
                          @"COUPONS",
                          @"GOLD",
                          @"GOOD_KILL",
                          @"MARKET_CATEGORY",
                          @"SHARE",
                          @"COMBO_ROOM",
                          @"TO_RESERVATION",
                          @"DESIGN_DETAIL",
                          @"FITTING_ROOM",
                          @"CASE_LIST",
                          @"DESIGNER_LIST",
                          @"MINE_HOME",
                          @"H5_BBS",
                          @"MARKET_HARDWARE",
                          nil];
    
    ShowCaseOperationType type = [typeArray indexOfObject:operationType];
    return type;
}

/*-----------------------h5调用native-------------------------*/
//http://10.199.39.25:8090/pages/viewpage.action?pageId=6063663

+ (void)handleOpenURL:(NSURL *)url viewController:(UIViewController *)viewController {
    
    NSString *query = [NSString stringWithFormat:@"%@", url];
    
    NSArray *queryArray22 = [query componentsSeparatedByString:@"="];
    NSMutableDictionary *resDic = [NSMutableDictionary dictionary];
    for (NSString *string in queryArray22) {
        NSRange range = [string rangeOfString:@":"];//获取第一次出现的位置
        if(range.location == NSNotFound){
            continue;
        }
        
        NSString *strTemp = [string stringByReplacingCharactersInRange:range withString:@"$$$"];
        NSArray *stringArray = [strTemp componentsSeparatedByString:@"$$$"];
        if (stringArray.count>1) {
            [resDic setObject:[NSString stringWithFormat:@"%@", stringArray[1]] forKey:[NSString stringWithFormat:@"%@", stringArray[0]]];
        }
    }
    [Assistant jumpWithDic:resDic viewController:viewController];
    
}

+ (void)handleOpen3DURL:(NSURL *)url viewController:(UIViewController *)viewController {
    NSString *query = [NSString stringWithFormat:@"%@", url];
    query = [query stringByReplacingOccurrencesOfString:@"=" withString:@"\":\""];
    query = [query stringByReplacingOccurrencesOfString:@"&" withString:@"\"=\""];
    NSArray *queryArray = [query componentsSeparatedByString:@"="];
    NSString *resultQuery =  [NSString stringWithFormat:@"{\"%@\"}", [queryArray componentsJoinedByString: @","]];
    NSDictionary *resultDic = [Assistant dictionaryWithJsonString: resultQuery];
    NSLog(@"%@", resultDic);
    [Assistant jumpWithDic:resultDic viewController:viewController];
    
}

+ (void)jumpWithDic:(NSDictionary *)dic viewController:(UIViewController *)viewController {
    NSString *placeStr = dic[@"operationtype"] ? dic[@"operationtype"] : @"";
    NSString *operationType = dic[@"operationType"] ? dic[@"operationType"] : placeStr;
    if ([operationType isEqualToString:@""]) {
        return;
    }
    if ([viewController isKindOfClass:[JRWebViewController class]]) {
        JRWebViewController *webView = (JRWebViewController *)viewController;
        [webView.webView stopLoading];
    }
    ShowCaseOperationType opType = [Assistant typeOfOperationType:operationType];
    
    switch (opType) {
        case H5: {//H5
            NSString *placeUrl = dic[@"operationcontent"] ? dic[@"operationcontent"] : @"";
            NSString *sUrl = dic[@"operationContent"] ? dic[@"operationContent"] : placeUrl;
            JRWebViewController *webViewCon = [[JRWebViewController alloc] init];
            if ([sUrl hasPrefix:@"http"]) {
                [webViewCon setTitle:@"" url:sUrl];
            } else {
                [webViewCon setTitle:@"" url:[NSString stringWithFormat:@"%@/%@",[JRNetEnvConfig sharedInstance].netEnvModel.host, sUrl]];
            }
            
            webViewCon.hidesBottomBarWhenPushed = YES;
            [viewController.navigationController pushViewController:webViewCon animated:YES];
            break;
        }
        case CALL: {//打电话
            NSString *placephone = dic[@"operationcontent"] ? dic[@"operationcontent"] : @"";
            NSString *phone = dic[@"operationContent"] ? dic[@"operationContent"] : placephone;
            if (phone == nil || [phone isEqualToString:@""] || phone.length < 1) {
                return;
            }
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        }
        case BACK: {//返回上一页
            [viewController.navigationController popViewControllerAnimated:YES];
            break;
        }
        case CREAT_PACKAGE: {//创建北舒套餐
            NSString *name = dic[@"name"] ? dic[@"name"] : @"";
            NSString *phone = dic[@"mobile"] ? dic[@"mobile"] : @"";
            NSString *uid = dic[@"uid"] ? dic[@"uid"] : @"";
            NSString *memId = dic[@"memberid"] ? dic[@"memberid"] : @"";
            name = [name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:name forKey:@"name"];
            [info setObject:phone forKey:@"mobile_number"];
            [info setObject:uid forKey:@"hs_uid"];
            [info setObject:memId forKey:@"member_id"];
            [MGJRouter openURL:@"/Design/CreatePackage" withUserInfo:info completion:nil];
            break;
        }
        case PACKAGE_HOME: {//套餐首页
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:@"YES" forKey:@"isFromHome"];
            [MGJRouter openURL:@"/Design/PackageHome" withUserInfo:info completion:nil];
            break;
        }
        case GOOD_DETAIL: {//商品详情
            
            NSString *designerid = dic[@"designerId"] ? dic[@"designerId"] : @"";
            if ([designerid isEqualToString:@""] || designerid == nil) {
                designerid = dic[@"designerid"] ? dic[@"designerid"] : @"";
            }
            NSString *goodid = dic[@"sku"] ? dic[@"sku"] : @"";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:designerid forKey:@"designerid"];
            [info setObject:goodid forKey:@"goodid"];
            [MGJRouter openURL:@"/Mall/GoodDetail" withUserInfo:info completion:nil];
            
            break;
        }
        case DECORATION: {//我要装修
            [MGJRouter openURL:@"/Design/Decoration"];
            break;
        }
        case MASTERIAL_HOME: {//商城首页
            [MGJRouter openURL:@"/Mall/MallHome"];
            break;
        }
            
        case DESIGNER_DATAIL: {//设计师详情
            NSString *mid = dic[@"memberid"] ? dic[@"memberid"] : @"";
            NSString *hsuid = dic[@"hsuid"] ? dic[@"hsuid"] : @"";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:mid forKey:@"mid"];
            [info setObject:hsuid forKey:@"hsuid"];
            [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:info completion:nil];
            break;
        }
        case EXAMPLE_DATAIL: {//案例详情
            NSString *caseid = dic[@"caseid"] ? dic[@"caseid"] : @"";
            NSString *isnew = dic[@"isnew"] ? dic[@"isnew"] : @"0";
            NSString *type = dic[@"type"] ? dic[@"type"] : @"0";
            NSString *source = dic[@"source"] ?: @"1";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:caseid forKey:@"caseid"];
            [info setObject:isnew forKey:@"isnew"];
            [info setObject:type forKey:@"type"];
            [info setObject:source forKey:@"source"];
            [MGJRouter openURL:@"/Design/Example" withUserInfo:info completion:nil];
            break;
        }
        case DESIGN_DATAIL: {//设计详情
            NSString *designid = dic[@"designid"] ? dic[@"designid"] : @"";
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:designid forKey:@"designid"];
            [MGJRouter openURL:@"/Design/DesignDetail" withUserInfo:info completion:nil];
            break;
        }
        case BACK_ROOT: {//返回首页
            [viewController.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        case LOGIN: {//登录
            [MGJRouter openURL:@"/UserCenter/LogIn"];
            break;
        }
        case GET_TOKEN: {//获取TOKEN
            if ([viewController isKindOfClass:[JRWebViewController class]]) {
                JRWebViewController *vc = (JRWebViewController *)viewController;
                NSString *token = [JRKeychain loadSingleUserInfo:UserInfoCodeXToken];
                NSString *member_id = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
                NSString *type = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
                NSString *jsFunction = [NSString stringWithFormat:@"getStatus('%@', '%@', '%@')", token, type, member_id];
                [vc.webView evaluateJavaScript:jsFunction completionHandler:nil];
            }
            break;
        }
        case CREAT_PROMOTION://创建施工项目
        {
            NSString *name = dic[@"name"] ?: @"";
            NSString *phone = dic[@"mobile"] ?: @"";
            NSString *uid = dic[@"uid"] ?: @"";
            NSString *memId = dic[@"memberid"] ?: @"";
            name = [name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:name forKey:@"name"];
            [info setObject:phone forKey:@"mobile_number"];
            [info setObject:uid forKey:@"hs_uid"];
            [info setObject:memId forKey:@"member_id"];
            [MGJRouter openURL:@"/Design/CreateConstruction" withUserInfo:info completion:nil];
            break;
        }
            
        case COUPONS: {//优惠券
            [MGJRouter openURL:@"/UserCenter/MyCoupons"];
            break;
        }
            
        case GOLD: {//金币
            [MGJRouter openURL:@"/UserCenter/MyGold"];
            break;
        }
            
        case GOOD_KILL: {//秒杀商品详情
            NSString *goodid = dic[@"goodid"] ? dic[@"goodid"] : @"";
            NSString *flashid = dic[@"flashid"] ? dic[@"flashid"] : @"";
            NSString *activityid = dic[@"activityid"] ? dic[@"activityid"] : @"";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:flashid forKey:@"flashid"];
            [info setObject:goodid forKey:@"goodid"];
            [info setObject:activityid forKey:@"activityid"];
            [MGJRouter openURL:@"/Mall/GoodDetail" withUserInfo:info completion:nil];
            break;
        }
            
        case MARKET_CATEGORY: {//丽屋超市品类列表
            
            NSString *categoryid = dic[@"categoryid"] ? dic[@"categoryid"] : @"";
            NSString *title = dic[@"title"] ? dic[@"title"] : @"";
            NSString *catalogid = dic[@"catalogid"] ? dic[@"catalogid"] : @"";
            title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:categoryid forKey:@"categoryid"];
            [info setObject:title forKey:@"title"];
            [info setObject:catalogid forKey:@"catalogid"];
            [MGJRouter openURL:@"/Mall/LiwuMarketList" withUserInfo:info completion:nil];
            
            break;
        }
        case SHARE: {//分享
            
            NSString *title = dic[@"title"] ? dic[@"title"] : @"";
            title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *content = dic[@"content"] ? dic[@"content"] : @"";
            content = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *image = dic[@"image"] ? dic[@"image"] : @"";
            NSString *url = dic[@"url"] ? dic[@"url"] : @"";
            NSString *platformstyle = dic[@"platformstyle"] ? dic[@"platformstyle"] : @"";
            
            ShareStyle type = ShareStyleTextAndImage;
            if ([platformstyle isEqualToString:@"Image"]) {
                type = ShareStyleImage;
            }
            [ESShareView showShareViewWithShareTitle:title shareContent:content shareImg:image shareUrl:url shareStyle:type Result:^(PlatformType type, BOOL isSuccess) {
            }];
            
            break;
        }
        case TO_RESERVATION:{//套餐免费预约
            
            NSString *type = dic[@"type"] ? dic[@"type"] : @"";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:type forKey:@"type"];
            
            [MGJRouter openURL:@"Design/FreeAppoint" withUserInfo:info completion:nil];
            
            break;
        }
            
        default:
            break;
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//商城之后showCase跳转
+ (void)jumpWithShowCaseDic:(NSDictionary *)dic viewController:(UIViewController *)viewController {
    NSString *operationType = dic[@"operation_type"] ? dic[@"operation_type"] : @"";
    if ([operationType isEqualToString:@""]) {
        return;
    }
    
    ShowCaseOperationType opType = [Assistant typeOfOperationType:operationType];
    NSDictionary *extend_dic = dic[@"extend_dic"] ? dic[@"extend_dic"] : [NSDictionary dictionary];
    switch (opType) {
        case H5: {//H5
            NSString *sUrl = extend_dic[@"url"] ? extend_dic[@"url"] : @"";
            JRWebViewController *webViewCon = [[JRWebViewController alloc] init];
            if ([sUrl hasPrefix:@"http"]) {
                [webViewCon setTitle:@"" url:sUrl];
            } else {
                [webViewCon setTitle:@"" url:[NSString stringWithFormat:@"%@/%@",[JRNetEnvConfig sharedInstance].netEnvModel.host, sUrl]];
            }
            
            webViewCon.hidesBottomBarWhenPushed = YES;
            [viewController.navigationController pushViewController:webViewCon animated:YES];
            break;
        }
        case PACKAGE_HOME: {//套餐首页
            [MGJRouter openURL:@"/Design/PackageHome"];
            break;
        }
        case DECORATION: {//我要装修
            [MGJRouter openURL:@"/Design/Decoration"];
            break;
        }
            
        case DESIGNER_DATAIL: {//设计师详情
            NSString *mid = extend_dic[@"member_id"] ? extend_dic[@"member_id"] : @"";
            NSString *hsuid = extend_dic[@"uid"] ? extend_dic[@"uid"] : @"";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:mid forKey:@"mid"];
            [info setObject:hsuid forKey:@"hsuid"];
            [MGJRouter openURL:@"/Design/DesignerDetail" withUserInfo:info completion:nil];
            break;
        }
        case EXAMPLE_DATAIL: {//案例详情
            NSString *caseid = dic[@"case_id"] ? dic[@"case_id"] : @"";
            NSString *isnew = dic[@"is_new"] ? dic[@"is_new"] : @"0";
            NSString *type = dic[@"type"] ? dic[@"type"] : @"0";
            
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:caseid forKey:@"caseid"];
            [info setObject:isnew forKey:@"isnew"];
            [info setObject:type forKey:@"type"];
            [info setObject:@"1" forKey:@"source"];
            [MGJRouter openURL:@"/Design/Example" withUserInfo:info completion:nil];
            break;
        }
        case CALL: {//打电话
            NSString *phone = [NSString stringWithFormat:@"%@", extend_dic[@"mobile_number"] ? extend_dic[@"mobile_number"] : @""];
            
            if (phone == nil || [phone isEqualToString:@""] || phone.length < 1) {
                return;
            }
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
            break;
        }
        case BACK: {//返回上一页
            [viewController.navigationController popViewControllerAnimated:YES];
            break;
        }
            
        case GOOD_DETAIL: {//商品详情
            NSString *goodid = [NSString stringWithFormat:@"%@", extend_dic[@"resourceId"] ? extend_dic[@"resourceId"] : @""];
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:goodid forKey:@"goodid"];
            [MGJRouter openURL:@"/Mall/GoodDetail" withUserInfo:info completion:nil];
            break;
        }
        case MASTERIAL_HOME: {//商城首页
            [MGJRouter openURL:@"/Mall/MallHome"];
            break;
        }
        case COMBO_ROOM:{
            [MGJRouter openURL:@"/Design/PackageHomeList"];
            break;
        }
        case DESIGN_DETAIL: {
            NSString *designid = extend_dic[@"design_id"] ? extend_dic[@"design_id"] : @"";
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            [info setObject:designid forKey:@"designid"];
            [MGJRouter openURL:@"/Design/DesignDetail" withUserInfo:info completion:nil];
            break;
        }
        case FITTING_ROOM:
        {
            [MGJRouter openURL:@"/Case/List/FittingRoom"];
            break;
        }
        case CASE_LIST:
        {
            [MGJRouter openURL:@"/Case/List/CaseList"];
            break;
        }
        case DESIGNER_LIST:
        {
            [MGJRouter openURL:@"/Designer/List/DesignerList"];
            break;
        }
        case MINE_HOME:
        {
            [MGJRouter openURL:@"/My/Mine_Home"];
            break;
        }
        case H5_BBS:
        {// 论坛相关的H5, 用以隐藏原生导航
            NSString *sUrl = extend_dic[@"url"] ? extend_dic[@"url"] : @"";
            JRWebViewController *webViewCon = [[JRWebViewController alloc] init];
            if ([sUrl hasPrefix:@"http"]) {
                [webViewCon setTitle:@"" url:sUrl];
            } else {
                [webViewCon setTitle:@"" url:[NSString stringWithFormat:@"%@/%@",[JRNetEnvConfig sharedInstance].netEnvModel.host, sUrl]];
            }
            [webViewCon setNavigationBarHidden:YES
                                 hasBackButton:NO];
            [webViewCon hideRefreshStatus];
            webViewCon.hidesBottomBarWhenPushed = YES;
            [viewController.navigationController pushViewController:webViewCon animated:YES];
            break;
        }
        case MARKET_HARDWARE:
        {
            [MGJRouter openURL:@"market/Hardware"];
            break;
        }
        default:
            break;
    }
}

@end

