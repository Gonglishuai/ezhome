//
//  JRWebViewController.m
//  Consumer
//
//  Created by jiang on 2017/5/22.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRWebViewController.h"

#import "Assistant.h"
#import "UMengServices.h"
#import "JRKeychain.h"
//#import "AppConstants.h"
//#import "MJRefresh.h"
#import "MBProgressHUD+NJ.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Masonry.h"
#import "ESOrientationManager.h"
#import <ESBasic/ESDevice.h>
#import "DefaultSetting.h"
#import "ESFoundationAssets.h"
#import "ESDiyRefreshHeader.h"
#import "UIColor+Stec.h"
#import "UIFont+Stec.h"
#import "JRNetEnvConfig.h"
#import <ESBasic/ESDevice.h>
#import <ESLoginManager.h>

// 解决与js通信是无法dealloc的问题
@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end

@implementation WeakScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}

- (void)dealloc
{
    SHLog(@"scriptDelegate dealloc");
}

@end

@interface JRWebViewController ()
<
WKUIDelegate,
WKScriptMessageHandler,
UINavigationControllerDelegate,
WKNavigationDelegate,
ESLoginManagerDelegate
>

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, assign) BOOL hiddenNav;
@property (nonatomic, assign) BOOL hiddenNavAndHasBackButton;
@property (nonatomic, strong) WeakScriptMessageDelegate *weakDelegate;

@end

@implementation JRWebViewController
{
    BOOL _statusBarHiddenInited;
    BOOL _refreshStatus;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _refreshStatus = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title url:(NSString *)url
{
    _titleStr = title;
    _urlStr = url;
}

- (void)hideRefreshStatus
{
    _refreshStatus = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = _titleStr;
    self.rightButton.hidden = YES;
    self.leftButton.hidden = NO;
    
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    
    [self initWebView];
    
    if (self.hiddenNav)
    {
        self.navgationImageview.hidden = YES;
        
        if (self.hiddenNavAndHasBackButton)
        {
            UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            backBtn.frame = CGRectMake(0, STATUSBAR_HEIGHT, 44, 44);
            [backBtn setImage:[ESFoundationAssets bundleImage:@"master_leftArrow"] forState:UIControlStateNormal];
            [backBtn addTarget:self action:@selector(tapOnLeftButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:backBtn];
        }
    }
    else
    {
        self.navgationImageview.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.hiddenNavAndHasBackButton)
    {
        _statusBarHiddenInited = [UIApplication sharedApplication].statusBarHidden;
        [UIApplication sharedApplication].statusBarHidden = YES;
        [ESOrientationManager setAllowRotation:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    
    if (self.hiddenNavAndHasBackButton)
    {
        [ESOrientationManager setAllowRotation:NO];
    }
}

- (void)setNavigationBarHidden:(BOOL)hidden hasBackButton:(BOOL)hasBack;
{
    self.hiddenNav = hidden;
    self.hiddenNavAndHasBackButton = hasBack;
}

- (void)tapOnLeftButton:(id)sender
{
    if (self.navigationController.topViewController == self && self.navigationController.viewControllers.count > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)initWebView
{
    [self updateUserAgent];
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    self.weakDelegate = [[WeakScriptMessageDelegate alloc] initWithDelegate:self];
    [webConfig.userContentController addScriptMessageHandler:self.weakDelegate name:@"webViewApp"];
    [webConfig.userContentController addScriptMessageHandler:self.weakDelegate name:@"downloadHomestyler"];
    //    [webConfig.userContentController addScriptMessageHandler:self.weakDelegate name:@"App"];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webConfig];
    [self addCookie];
    
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    __block UIView *b_view = self.view;
    if (self.hiddenNav) {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(b_view.mas_top);
            make.leading.equalTo(b_view.mas_leading);
            make.trailing.equalTo(b_view.mas_trailing);
            make.bottom.equalTo(b_view.mas_bottom);
        }];
    }else {
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(b_view.mas_top).with.offset(NAVBAR_HEIGHT);
            make.leading.equalTo(b_view.mas_leading);
            make.trailing.equalTo(b_view.mas_trailing);
            make.bottom.equalTo(b_view.mas_bottom);
        }];
    }
    
    
    SHLog(@"%@", _urlStr);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_urlStr]];
    [_webView loadRequest:request];
    
    if (_refreshStatus)
    {
        [self addRefresh];
    }
}

- (void)addRefresh
{
    ESDiyRefreshHeader *header = [ESDiyRefreshHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(refreshWebview)];
    _webView.scrollView.mj_header = header;
    _webView.scrollView.mj_header.automaticallyChangeAlpha = YES;
}

- (void)updateUserAgent
{
    //获取旧的UserAgent
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    SHLog(@"old agent :%@", oldAgent);
    
    if ([oldAgent rangeOfString:@"juranShejijia-ios-"].length <= 0)
    {
        //添加新的UserAgent
        NSString *newAgent = [NSString stringWithFormat:@"juranShejijia-ios-%@;%@", [ESDevice deviceModel], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        SHLog(@"new agent :%@", newAgent);
        
        //保存添加后的UserAgent
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent,@"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
}

- (void)refreshWebview {
    
    [self addCookie];
    
    [self.webView reload];
    [_webView.scrollView.mj_header endRefreshing];
}

- (void)addCookie {
    
    NSString *sourceCookieStr = [NSString stringWithFormat:@"sjjsource=ios"];
    NSString *sourceScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", sourceCookieStr];
    WKUserScript *sourceUserScript = [[WKUserScript alloc] initWithSource:sourceScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webView.configuration.userContentController addUserScript:sourceUserScript];
    SHLog(@"tkCookieStr------%@", sourceCookieStr);
    
    
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeXToken] isEqualToString:@""]) {
        NSString *tkCookieStr = [NSString stringWithFormat:@"token=%@", [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];
        NSString *tkScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", tkCookieStr];
        WKUserScript *tkUserScript = [[WKUserScript alloc] initWithSource:tkScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:tkUserScript];
        SHLog(@"tkCookieStr------%@", tkCookieStr);
    }
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeType] isEqualToString:@""]) {
        NSString *memberTypeCookieStr = [NSString stringWithFormat:@"member_type=%@", [JRKeychain loadSingleUserInfo:UserInfoCodeType]];
        NSString *memberTypeScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", memberTypeCookieStr];
        WKUserScript *memberTypeUserScript = [[WKUserScript alloc] initWithSource:memberTypeScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:memberTypeUserScript];
        SHLog(@"memberTypeCookieStr-------%@", memberTypeCookieStr);
    }
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodePhone] isEqualToString:@""]) {
        NSString *phoneCookieStr = [NSString stringWithFormat:@"phone=%@", [JRKeychain loadSingleUserInfo:UserInfoCodePhone]];
        NSString *phoneScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", phoneCookieStr];
        WKUserScript *phoneUserScript = [[WKUserScript alloc] initWithSource:phoneScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:phoneUserScript];
        SHLog(@"phoneCookieStr----------%@", phoneCookieStr);
    }
    
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeJId] isEqualToString:@""]) {
        NSString *member_idCookieStr = [NSString stringWithFormat:@"member_id=%@", [JRKeychain loadSingleUserInfo:UserInfoCodeJId]];
        NSString *member_idScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", member_idCookieStr];
        WKUserScript *member_idUserScript = [[WKUserScript alloc] initWithSource:member_idScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:member_idUserScript];
        SHLog(@"phoneCookieStr----------%@", member_idCookieStr);
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *versionCookieStr = [NSString stringWithFormat:@"app_version=%@", app_version];
    NSString *versionScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", versionCookieStr];
    WKUserScript *versionUserScript = [[WKUserScript alloc] initWithSource:versionScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webView.configuration.userContentController addUserScript:versionUserScript];
    SHLog(@"versionCookieStr--------%@", versionCookieStr);
    
    NSString *app_typeCookieStr = [NSString stringWithFormat:@"app_type=%@", @"consumer"];
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        app_typeCookieStr = [NSString stringWithFormat:@"app_type=%@", @"mall"];
    }
    NSString *app_typeScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", app_typeCookieStr];
    WKUserScript *app_typeUserScript = [[WKUserScript alloc] initWithSource:app_typeScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webView.configuration.userContentController addUserScript:app_typeUserScript];
    SHLog(@"phoneCookieStr----------%@", app_typeCookieStr);
    
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeXToken] isEqualToString:@""]) {
        
        NSString *subStr = [JRNetEnvConfig sharedInstance].netEnvModel.envFlag;

        NSString *sjj_token = [NSString stringWithFormat:@"sjj_token_%@=%@", subStr, [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];
        NSString *sjj_tokenScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", sjj_token];
        WKUserScript *sjj_tokenUserScript = [[WKUserScript alloc] initWithSource:sjj_tokenScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:sjj_tokenUserScript];
        SHLog(@"sjj_token------%@", sjj_token);
    }
    
    NSString *loginSubStr = [JRNetEnvConfig sharedInstance].netEnvModel.envFlag;

    NSString *app_has_login = [NSString stringWithFormat:@"has_login_%@=%@", loginSubStr, [ESLoginManager sharedManager].isLogin?@"true":@"false"];
    NSString *app_has_loginScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", app_has_login];
    WKUserScript *app_has_loginUserScript = [[WKUserScript alloc] initWithSource:app_has_loginScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [_webView.configuration.userContentController addUserScript:app_has_loginUserScript];
    SHLog(@"app_has_loginUserScript----------%@", app_has_loginUserScript);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([@"downloadHomestyler" isEqualToString:message.name])
    {
        SHLog(@"downloadHomestyler:%@", message.body);
        NSString *homeStylerDownloadUrl = message.body;
        if ([homeStylerDownloadUrl isKindOfClass:[NSString class]])
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:homeStylerDownloadUrl]])
            {
                [UMengServices eventWithEventId:Event_homestylerDownloadCount attributes:@{@"日期": [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterFullStyle timeStyle:NSDateFormatterFullStyle]}];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:homeStylerDownloadUrl]];
            }
        }
    }
    //    else if ([@"App" isEqualToString:message.name]) {
    //        SHLog(@"App--------------------App\n%@\nApp--------------------App", message.body);
    //        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:message.body];
    //        [Assistant jumpToProduct:dic viewController:self];
    //    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    WS(weakSelf)
    
    [webView evaluateJavaScript:(@"document.cookie") completionHandler:^(NSString* result, NSError * _Nullable error) {
        NSString *cookie = [NSString stringWithFormat:@"%@", result ? result :  @""];
        SHLog(@"cookie-------%@", cookie);
    }];
    
    [webView evaluateJavaScript:(@"document.title") completionHandler:^(NSString* result, NSError * _Nullable error) {
        NSString *title = weakSelf.titleStr ? weakSelf.titleStr : @"";
        if (result != nil && result.length > 0) {
            title = result;
        }
        weakSelf.titleLabel.text = title;
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *redirectURL = navigationAction.request.URL;
    SHLog(@"redirectURL-------%@", redirectURL);
    NSString *query = [NSString stringWithFormat:@"%@", redirectURL];
    
    if ([query containsString:@"GOOD_DETAIL"]) {
        NSArray *queryArray = [query componentsSeparatedByString:@"?"];
        NSString *urlStr = [NSString stringWithFormat:@"%@", queryArray.lastObject];
        NSURL *url = [NSURL URLWithString:urlStr];
        [Assistant handleOpen3DURL:url viewController:self];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        NSArray *queryArray = [query componentsSeparatedByString:@"??"];
        NSString *urlStr = [NSString stringWithFormat:@"%@", queryArray.lastObject];
        NSURL *url = [NSURL URLWithString:urlStr];
        [Assistant handleOpenURL:url viewController:self];
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

#pragma mark - ESLoginManagerDelegate
- (void)onLogin {
    [self refreshWebview];
}

- (void)onLogout {
    [self refreshWebview];
}

- (void)dealloc
{
    [_webView stopLoading];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"webViewApp"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"App"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"downloadHomestyler"];
    [[ESLoginManager sharedManager] removeLoginDelegate:self];
    self.weakDelegate = nil;
    SHLog(@"dealloc");
}

@end

