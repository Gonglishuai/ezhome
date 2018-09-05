//
//  ESIMSessionViewController.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESIMSessionViewController.h"
#import "ESTimerHolder.h"
#import "NIMKitMediaFetcher.h"
#import "ESSessionConfig.h"
#import "ESSubscribeManager.h"
#import "ESSessionUtil.h"
#import "UIView+Toast.h"
#import "ESIMGalleryViewController.h"
#import "ESIMVideoViewController.h"
#import "NIMKitLocationPoint.h"
#import "NIMLocationViewController.h"
#import "ESFilePreViewController.h"
#import "Reachability.h"
#import "ESIMCustomSysNotificationSender.h"

@interface ESIMSessionViewController ()
<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
NIMSystemNotificationManagerDelegate,
NIMMediaManagerDelegate,
ESTimerHolderDelegate
>
@property (nonatomic, strong) ESIMCustomSysNotificationSender *notificaionSender;
@property (nonatomic, strong) ESSessionConfig       *sessionConfig;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) ESTimerHolder         *titleTimer;
@property (nonatomic, strong) UIView *currentSingleSnapView;
@property (nonatomic, strong) NIMKitMediaFetcher *mediaFetcher;
@end

@implementation ESIMSessionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Temp
    
    _notificaionSender  = [[ESIMCustomSysNotificationSender alloc] init];
    
    BOOL disableCommandTyping = self.disableCommandTyping || (self.session.sessionType == NIMSessionTypeP2P &&[[NIMSDK sharedSDK].userManager isUserInBlackList:self.session.sessionId]);
    if (!disableCommandTyping) {
        _titleTimer = [[ESTimerHolder alloc] init];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
    }
    
//    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
//    {
//        //临时订阅这个人的在线状态
//        [[ESSubscribeManager sharedManager] subscribeTempUserOnlineState:self.session.sessionId];
//        [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
//    }
    
    //删除最近会话列表中有人@你的标记
    [ESSessionUtil removeRecentSessionAtMark:self.session];
    
    [self setupNavigation];
    
    if (self.isManufacturer) {
        [self setUpAlertTopView];
    }
    [self.navigationItem.titleView layoutIfNeeded];
}

- (void)setUpAlertTopView {
    UIView *alertTopView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    alertTopView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:alertTopView atIndex:0];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 17.5, 15, 15)];
    [icon setImage:[UIImage imageNamed:@"im_tip"]];
    [alertTopView addSubview:icon];
    
    UILabel *tipText = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 60, 50)];
    tipText.text = @"由于咨询量大及客服繁忙，若您未及时收到回复，可以拨打商品详情页中的电话。";
    tipText.numberOfLines = 2;
    [tipText setFont:[UIFont stec_remarkTextFount]];
    [tipText setTextColor:ColorFromRGA(0xcccccc, 1)];
    [alertTopView addSubview:tipText];
    [self.view bringSubviewToFront:alertTopView];
    
    CGRect frame = self.tableView.frame;
    frame = CGRectMake(frame.origin.x, 50, frame.size.width, frame.size.height - 50);
    self.tableView.frame = frame;
    [self.view layoutIfNeeded];
}

- (void)setupNavigation {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)dealloc {
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
    {
//        [[NIMSDK sharedSDK].subscribeManager removeDelegate:self];
        [[ESSubscribeManager sharedManager] unsubscribeTempUserOnlineState:self.session.sessionId];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NIMSDK sharedSDK].mediaManager stopRecord];
    [[NIMSDK sharedSDK].mediaManager stopPlay];
}

- (id<NIMSessionConfig>)sessionConfig {
    if (_sessionConfig == nil) {
        _sessionConfig = [[ESSessionConfig alloc] init];
        _sessionConfig.session = self.session;
        _sessionConfig.isManufacturer = self.isManufacturer;
    }
    return _sessionConfig;
}

//#pragma mark - NIMEventSubscribeManagerDelegate
//- (void)onRecvSubscribeEvents:(NSArray *)events
//{
//    for (NIMSubscribeEvent *event in events) {
//        if ([event.from isEqualToString:self.session.sessionId]) {
//            [self refreshSessionSubTitle:[ESSessionUtil onlineState:self.session.sessionId detail:YES]];
//        }
//    }
//}
//
//- (void)onNTESTimerFired:(ESTimerHolder *)holder {
//    [self refreshSessionTitle:self.sessionTitle];
//}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    if (!notification.sendToOnlineUsersOnly) {
        return;
    }
    NSData *data = [[notification content] dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        if ([self jsonIntegerWithDict:dict withKey:ESNotifyID] == ESCommandTyping && self.session.sessionType == NIMSessionTypeP2P && [notification.sender isEqualToString:self.session.sessionId])
        {
            [self refreshSessionTitle:@"正在输入..."];
            [_titleTimer startTimer:5
                           delegate:self
                            repeats:NO];
        }
    }
    
    
}

- (NSInteger)jsonIntegerWithDict:(NSDictionary *)dict withKey:(NSString *)key {
    id object = [dict objectForKey:key];
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]])
    {
        return [object integerValue];
    }
    return 0;
}

- (void)onESTimerFired:(ESTimerHolder *)holder {
    [self refreshSessionTitle:self.sessionTitle];
}

- (NSString *)sessionTitle {
    if ([self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return  @"我的电脑";
    }
    return [super sessionTitle];
}

- (NSString *)sessionSubTitle {
    if (self.session.sessionType == NIMSessionTypeP2P && ![self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return [ESSessionUtil onlineState:self.session.sessionId detail:YES];
    }
    return @"";
}

- (void)onTextChanged:(id)sender {
    [_notificaionSender sendTypingState:self.session];
}

#pragma mark - 录音事件
- (void)onRecordFailed:(NSError *)error
{
    [self.view makeToast:@"录音失败" duration:2 position:CSToastPositionCenter];
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 2;
}

- (void)showRecordFileNotSendReason
{
    [self.view makeToast:@"录音时间太短" duration:0.2f position:CSToastPositionCenter];
}

#pragma mark - Cell事件
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = [super onTapCell:event];
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMKitEventNameTapRobotLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
}

#pragma mark - Cell Actions
- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    ESIMGalleryItem *item = [[ESIMGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    ESIMGalleryViewController *vc = [[ESIMGalleryViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showVideo:(NIMMessage *)message
{
    NIMVideoObject *object = message.messageObject;
    ESIMVideoViewController *playerViewController = [[ESIMVideoViewController alloc] initWithVideoObject:object];
    [self.navigationController pushViewController:playerViewController animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
        //如果封面图下跪了，点进视频的时候再去下一把封面图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showLocation:(NIMMessage *)message
{
//    NIMLocationObject *object = message.messageObject;
//    NIMKitLocationPoint *locationPoint = [[NIMKitLocationPoint alloc] initWithLocationObject:object];
//    NIMLocationViewController *vc = [[NIMLocationViewController alloc] initWithLocationPoint:locationPoint];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showFile:(NIMMessage *)message
{
    NIMFileObject *object = message.messageObject;
    ESFilePreViewController *vc = [[ESFilePreViewController alloc] initWithFileObject:object];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showCustom:(NIMMessage *)message
{
    //普通的自定义消息点击事件可以在这里做哦~
}

- (void)openSafari:(NSString *)link
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:link];
    if (components)
    {
        if (!components.scheme)
        {
            //默认添加 http
            components.scheme = @"http";
        }
        [[UIApplication sharedApplication] openURL:[components URL]];
    }
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    if (defaultItems) {
        [items addObjectsFromArray:defaultItems];
    }
    
    if ([ESSessionUtil canMessageBeRevoked:message]) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessage:)]];
    }
    
    return items;
    
}

- (void)revokeMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                SHLog(@"revoke message eror code %zd",error.code);
                [weakSelf.view makeToast:@"消息撤回失败，请重试" duration:2.0 position:CSToastPositionCenter];
            }
        }
        else
        {
            NIMMessageModel *model = [self uiDeleteMessage:message];
            
            NIMMessage *tip         = [[NIMMessage alloc] init];
            NIMTipObject *tipObject = [[NIMTipObject alloc] init];
            tip.messageObject       = tipObject;
            tip.text                = [ESSessionUtil tipOnMessageRevoked:message];
            NIMMessageSetting *setting = [[NIMMessageSetting alloc] init];
            setting.apnsEnabled        = NO;
            setting.shouldBeCounted    = NO;
            tip.setting            = setting;
            
            message.timestamp = model.messageTime;
            [self uiInsertMessages:@[tip]];
            
            tip.timestamp = message.timestamp;
            // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
            [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
        }
    }];
}

#pragma mark - 辅助方法
- (void)sendImageMessagePath:(NSString *)path
{
    
}


- (BOOL)checkRTSCondition
{
    BOOL result = YES;
    
    if (![[Reachability reachabilityForInternetConnection] isReachable])
    {
        [self.view makeToast:@"请检查网络" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    if (self.session.sessionType == NIMSessionTypeP2P && [currentAccount isEqualToString:self.session.sessionId])
    {
        [self.view makeToast:@"不能和自己通话哦" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
        NSInteger memberNumber = team.memberNumber;
        if (memberNumber < 2)
        {
            [self.view makeToast:@"无法发起，群人数少于2人" duration:2.0 position:CSToastPositionCenter];
            result = NO;
        }
    }
    return result;
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
//                    @(NIMMessageTypeLocation) : @"showLocation:",
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (NIMKitMediaFetcher *)mediaFetcher
{
    if (!_mediaFetcher) {
        _mediaFetcher = [[NIMKitMediaFetcher alloc] init];
        _mediaFetcher.limit = 1;
        _mediaFetcher.mediaTypes = @[(NSString *)kUTTypeImage];;;
    }
    return _mediaFetcher;
}

- (BOOL)shouldAutorotate{
    return !self.currentSingleSnapView;
}

@end
