//
//  ESNIMManager.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESNIMManager.h"
#import <NIMSDK/NIMSDK.h>
#import "ESIMConfig.h"
#import <NIMKit/NIMKit.h>
#import "ESIMDataProviderImpl.h"
#import "JRKeychain.h"
#import "ESClientUtil.h"
#import "ESIMSessionViewController.h"
#import "ESMemberIdAPI.h"
#import "MBProgressHUD.h"
#import "CoStringManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ESSessionUtil.h"

@interface ESNIMManager()<NIMLoginManagerDelegate, NIMChatManagerDelegate>
@property (nonatomic, strong) NSMutableSet *delegates;
@end

@implementation ESNIMManager

+ (instancetype)sharedManager {
    static ESNIMManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ESNIMManager alloc] init];
    });
    return instance;
}

- (void)initNIM {
    NSString *appKey = [ESIMConfig sharedConfig].appKey;
    NSString *cerName = [ESIMConfig sharedConfig].apnsCername;
    
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:appKey];
    option.apnsCername = cerName;
    
    [[NIMSDK sharedSDK] registerWithOption:option];
    [NIMKit sharedKit].provider = [[ESIMDataProviderImpl alloc] init];
    
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    
    [self registerPushService];
    [self addLoginDelegate];
    [self autoLogin];
}

- (void)updateApnsToken:(NSData *)deviceToken {
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}

- (NSInteger)getNIMAllUnreadCount {
    return [[[NIMSDK sharedSDK] conversationManager] allUnreadCount];
}

- (BOOL)isLogined {
    return [NIMSDK sharedSDK].loginManager.isLogined;
}

#pragma mark - NIMLoginManagerDelegate
-(void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType {
    NSString *reason = @"您的账号在其他多台终端登录，为了您的账号安全，请重新登录";
//    switch (code) {
//        case NIMKickReasonByClient:
//        case NIMKickReasonByClientManually:{
//            NSString *clientName = [ESClientUtil clientName:clientType];
//            reason = clientName.length ? [NSString stringWithFormat:@"你的帐号被%@端踢出下线，请注意帐号信息安全",clientName] : @"你的帐号被踢出下线，请注意帐号信息安全";
//            break;
//        }
//        case NIMKickReasonByServer:
//            reason = @"你被服务器踢下线";
//            break;
//        default:
//            break;
//    }
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        [[ESLoginManager sharedManager] logout];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下线通知" message:reason preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [alert addAction:action];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)onAutoLoginFailed:(NSError *)error {
    SHLog(@"网易云信 自动登录失败 error：%@", error);
//    [SHAppGlobal AppGlobal_SetLoginStatus:NO];
//    [SHAppGlobal AppGlobal_ProccessLogout];
}

#pragma mark - NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages {
    [self refreshByNewMessage:[NIMSDK sharedSDK].conversationManager.allUnreadCount > 0];
}

- (void)onRecvRevokeMessageNotification:(NIMRevokeMessageNotification *)notification {
    NIMMessage *tip         = [[NIMMessage alloc] init];
    NIMTipObject *tipObject = [[NIMTipObject alloc] init];
    tip.messageObject       = tipObject;
    tip.text                = [ESSessionUtil tipOnMessageRevoked:notification];
    
    NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
    setting.shouldBeCounted    = NO;
    tip.setting            = setting;
    tip.timestamp = notification.timestamp;
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UITabBarController *tbVc = delegate.tbVC;
    UINavigationController *nav = tbVc.selectedViewController;
    
    for (ESIMSessionViewController *vc in nav.viewControllers) {
        if ([vc isKindOfClass:[ESIMSessionViewController class]]
            && [vc.session.sessionId isEqualToString:notification.session.sessionId]) {
            NIMMessageModel *model = [vc uiDeleteMessage:notification.message];
            if (model) {
                [vc uiInsertMessages:@[tip]];
            }
            break;
        }
    }
    
    // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
    [[NIMSDK sharedSDK].conversationManager saveMessage:tip
                                             forSession:notification.session
                                             completion:nil];
}

- (void)autoLogin {
    NSString *j_member_id = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *nim_token = [JRKeychain loadSingleUserInfo:UserInfoCodeNIMToken];
    
    //    //如果有缓存用户名密码推荐使用自动登录
    if ([j_member_id length] && [nim_token length]) {
        NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
        loginData.account = j_member_id;
        loginData.token = nim_token;
        loginData.forcedMode = YES;
        [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
    }else {
        [[ESLoginManager sharedManager] logout];
    }
}

- (void)manualLogin {
    NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
    loginData.account = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    loginData.token = [JRKeychain loadSingleUserInfo:UserInfoCodeNIMToken];
    loginData.forcedMode = YES;
    [[[NIMSDK sharedSDK] loginManager] login:loginData.account
                                       token:loginData.token
                                  completion:^(NSError * _Nullable error)
     {
         if (error == nil) {
             SHLog(@"网易云信 登录成功!");
         }else {
             SHLog(@"网易云信 登录error：%@", error);
         }
     }];
    
}

- (void)logout {
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError * _Nullable error) {
        if (error == nil) {
            SHLog(@"网易云信 登出成功!");
        }else {
            SHLog(@"网易云信 登出 error：%@", error);
        }
    }];
}

+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                withJMemberId:(NSString *)j_member_id
                    andSource:(ESIMSource) source {
    
    if (j_member_id && j_member_id.length > 0) {
        NSDictionary *tempSource = [ESNIMManager getSessionSource:source];
        [ESNIMManager sharedManager].source = tempSource;
        
        [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        NSDictionary *dict = @{@"data" : j_member_id};
        [ESNIMManager dataManageWithVC:viewController andDict:dict isManufacturer:NO];
    }
}

+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                      withUid:(NSString *)hs_uid
                    andSource:(ESIMSource) source {
    
    NSDictionary *tempSource = [ESNIMManager getSessionSource:source];
    [ESNIMManager sharedManager].source = tempSource;
    
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    __block UIViewController *b_viewController = viewController;
    
    [ESMemberIdAPI getMemberIdWithUid:hs_uid andSuccess:^(NSDictionary *dict) {
        [ESNIMManager dataManageWithVC:b_viewController andDict:dict isManufacturer:NO];
    } andFailure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:b_viewController.view animated:YES];
        });
    }];
}

+ (void)startP2PSessionFromVc:(UIViewController *)viewController
                 withDealerId:(NSString *)dealerId
                    andSource:(ESIMSource) source {
    
    NSDictionary *tempSource = [ESNIMManager getSessionSource:source];
    [ESNIMManager sharedManager].source = tempSource;
    
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    __block UIViewController *b_viewController = viewController;
    
    [ESMemberIdAPI getNimIdWithDealerId:dealerId andSuccess:^(NSDictionary *dict) {
        [ESNIMManager dataManageWithVC:b_viewController andDict:dict isManufacturer:YES];
    } andFailure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:b_viewController.view animated:YES];
        });
    }];
}

+ (void)dataManageWithVC:(UIViewController *)controller andDict:(NSDictionary *)dict isManufacturer:(BOOL)isManufacturer {
    NSString *j_member_id = [CoStringManager judgeNSString:dict forKey:@"data"];
    if ([j_member_id isEqualToString:@""]) {
        [self showErrorMsg:controller];
        return;
    }
    NIMUser *user = [[NIMSDK sharedSDK].userManager userInfo:j_member_id];
    if (user.userInfo.nickName == nil) {
        [[NIMSDK sharedSDK].userManager fetchUserInfos:@[j_member_id] completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:controller.view animated:YES];
                    UIViewController *vc = [[ESNIMManager sharedManager] startP2PSessionWithId:j_member_id isManufacturer:isManufacturer];
                    if (controller.navigationController) {
                        vc.hidesBottomBarWhenPushed = YES;
                        [controller.navigationController pushViewController:vc animated:YES];
                    }
                });
            }else {
                [self showErrorMsg:controller];
            }
        }];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:controller.view animated:YES];
            UIViewController *vc = [[ESNIMManager sharedManager] startP2PSessionWithId:j_member_id isManufacturer:isManufacturer];
            if (controller.navigationController) {
                vc.hidesBottomBarWhenPushed = YES;
                [controller.navigationController pushViewController:vc animated:YES];
            }
        });
    }
}

+ (void)showErrorMsg:(UIViewController *)vc {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:vc.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"网络错误, 请稍后重试!";
        hud.margin = 30.f;
        [hud setOffset:CGPointMake(hud.offset.x, 0)];
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.5];
    });
}

- (void)addESIMDelegate:(id<ESNIMManagerDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
       [self.delegates addObject:delegate];
    }
}

- (void)removeESIMDelegate:(id<ESNIMManagerDelegate>)delegate {
    if (self.delegates.count > 0 && [self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}
#pragma mark - private
- (void)registerPushService {
    //apns
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
}

- (void)addLoginDelegate {
    [[[NIMSDK sharedSDK] loginManager] addDelegate:self];
}

- (UIViewController *)startP2PSessionWithId:(NSString *)j_member_id isManufacturer:(BOOL)isManufacturer {
    NIMSession *session = [NIMSession session:j_member_id type:NIMSessionTypeP2P];
    ESIMSessionViewController *vc = [[ESIMSessionViewController alloc] initWithSession:session];
    vc.isManufacturer = isManufacturer;
    return vc;
}

+ (NSDictionary *)getSessionSource:(ESIMSource)source {
    NSString *str = nil;
    switch (source) {
        case ESIMSourceCaseDetail:
            str = @"CaseDetail";
            break;
        case ESIMSourceDesignerHome:
            str = @"DesignerHome";
            break;
        case ESIMSourceProjectDetail:
            str = @"ProjectDetail";
            break;
        case ESIMSourceProductDetail:
            str = @"ProductDetail";
        default:
            break;
    }
    if (str) {
        return @{@"source" : str};
    }
    
    return nil;
}

- (void)refreshByNewMessage:(BOOL)hasNewMsg {
    if (self.delegates.count > 0) {
//        SystemSoundID soundID = 1007;
//        AudioServicesPlaySystemSound(soundID);
        [self.delegates enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj respondsToSelector:@selector(hasNewMessage:)]) {
                [obj hasNewMessage:hasNewMsg];
            }
        }];
    }
}

- (NSMutableSet *)delegates {
    if (_delegates == nil) {
        _delegates = [NSMutableSet set];
    }
    return _delegates;
}

- (void)dealloc {
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}
@end
