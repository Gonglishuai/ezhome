
#import "ESPromotionUtil.h"
#import "JRWebViewController.h"

@interface ESPromotionUtil ()

@end

@implementation ESPromotionUtil

+ (void)showPromotionAlert:(NSDictionary *)userInfo
{
    if (!userInfo
        || ![userInfo isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSString *message = @"";
    if (userInfo[@"aps"]
        && [userInfo[@"aps"] isKindOfClass:[NSDictionary class]]
        && userInfo[@"aps"][@"alert"]
        && [userInfo[@"aps"][@"alert"] isKindOfClass:[NSString class]])
    {
        message = userInfo[@"aps"][@"alert"];
    }
    
    [SHAlertView showAlertWithTitle:@"提示"
                            message:message
                     cancelKeyTitle:@"取消"
                      rightKeyTitle:@"查看"
                           rightKey:^
     {
         if (userInfo[@"messageType"]
             && [userInfo[@"messageType"] isKindOfClass:[NSString class]]
             && [userInfo[@"messageType"] isEqualToString:@"MESSAGE_PROMOTION"]
             && userInfo[@"customData"]
             && [userInfo[@"customData"] isKindOfClass:[NSDictionary class]])
         {
             [ESPromotionUtil showPromotionViewWithUrl:userInfo[@"customData"][@"url"]
                                                  type:ESPromotionTypeForeground];
         }
     } cancelKey:^{
         
     }];

}

+ (void)showPromotionViewWithUrl:(NSString *)url
                            type:(ESPromotionType)type
{
    JRWebViewController *vc = [[JRWebViewController alloc] init];
    [vc setTitle:@"活动详情" url:url];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *viewController = [self getViewControllerWithType:type];
    if(viewController)
    {
        [viewController presentViewController:nvc
                                     animated:YES
                                   completion:nil];
    }
    
    
}

+ (UIViewController *)getViewControllerWithType:(ESPromotionType)type
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UITabBarController *tabController = (id)window.rootViewController;
    if (![tabController isKindOfClass:[UITabBarController class]])
    {
        return nil;
    }

    if ([tabController presentedViewController])
    {
        [tabController dismissViewControllerAnimated:NO completion:nil];
    }
    
    return tabController;
}

@end
