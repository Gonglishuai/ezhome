//
//  ESWeiboServices.m
//  Consumer
//
//  Created by jiang on 2017/10/17.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESWeiboServices.h"
#import "WeiboSDK.h"
#import "MBProgressHUD+NJ.h"
#import "JRNetEnvConfig.h"
#import "DefaultSetting.h"

@interface ESWeiboServices ()
@property (strong, nonatomic)weiboShareResultBlock resultBlock;
@end
@implementation ESWeiboServices

+ (instancetype)sharedInstance
{
    static ESWeiboServices *weiboServices = nil;
    static dispatch_once_t s_predicate;
    dispatch_once(&s_predicate, ^{
        weiboServices = [[super allocWithZone:NULL]init];
    });
    
    return weiboServices;
}


///override the function of allocWithZone:.
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    return [ESWeiboServices sharedInstance];
}


///override the function of copyWithZone:.
- (instancetype)copyWithZone:(struct _NSZone *)zone {
    
    return [ESWeiboServices sharedInstance];
}

- (void)setUpApiKey {
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:[JRNetEnvConfig sharedInstance].netEnvModel.weiboAppKey];
}

+ (BOOL)isWeiboAppInstalled {
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:[ESWeiboServices sharedInstance]];
}

- (void)sendSinaShareWithTitle:(NSString *)title
                       content:(NSString *)content
                         image:(UIImage *)image
                        urlStr:(NSString *)urlStr
                    shareStyle:(ShareStyle)shareStyle
                   resultBlock:(weiboShareResultBlock)resultBlock {
    self.resultBlock = resultBlock;
    WBAuthorizeRequest *authorizerequest = [WBAuthorizeRequest request];
    authorizerequest.shouldShowWebViewForAuthIfCannotSSO = YES;
    authorizerequest.redirectURI = [JRNetEnvConfig sharedInstance].netEnvModel.weiboRedirectURI;
    authorizerequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = [NSString stringWithFormat:@"%@%@%@", title, content, urlStr];
    
    if (image) {
        WBImageObject *imageObject = [WBImageObject object];
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        message.imageObject = imageObject;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authorizerequest access_token:nil];
    [WeiboSDK sendRequest:request];
    
}

// MARK: - WeiboSDKDelegate 代理回调
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"didReceiveWeiboRequest");
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    NSLog(@"didReceiveWeiboResponse");
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *resp = (WBAuthorizeResponse *)response;
        if (resp.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            NSLog(@"授权成功");
        } else {
            NSLog(@"新浪微博授权失败");
        }
    } else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        
        WBSendMessageToWeiboResponse *resp = (WBSendMessageToWeiboResponse *)response;
        BOOL isSucess = NO;
        NSString *strMsg = @"分享失败";
        switch (resp.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess: {
                strMsg = @"分享成功";
                isSucess = YES;
                break;
            }
            case WeiboSDKResponseStatusCodeUserCancel: {
                strMsg = @"用户取消发送";
                break;
            }
            case WeiboSDKResponseStatusCodeSentFail: {
                strMsg = @"发送失败";
                break;
            }
            case WeiboSDKResponseStatusCodeAuthDeny: {
                strMsg = @"授权失败";
                break;
            }
            case WeiboSDKResponseStatusCodeUserCancelInstall: {
                strMsg = @"用户取消安装微博客户端";
                break;
            }
            case WeiboSDKResponseStatusCodeShareInSDKFailed: {
                strMsg = @"分享失败";
                break;
            }
            case WeiboSDKResponseStatusCodePayFail: {
                strMsg = @"支付失败";
                break;
            }
            case WeiboSDKResponseStatusCodeUnsupport: {
                strMsg = @"不支持的请求";
                break;
            }
            case WeiboSDKResponseStatusCodeUnknown: {
                strMsg = @"未知错误";
                break;
            }
            default:
                break;
        }
        
        if (self.resultBlock) {
            self.resultBlock(isSucess);
        }
        [self showAleartWithTitle:strMsg];
    }
}

- (void)showAleartWithTitle:(NSString *)title{
    UIWindow *window  = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.margin = 30.f;
    [hud setOffset:CGPointMake(hud.offset.x, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1];
    
}
@end
