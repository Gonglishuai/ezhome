//
//  GenericWebViewBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import "GenericWebViewBaseViewController.h"
#import "NSString+Contains.h"
#import "ProgressViewController_iPhone.h"

#define PortraitWebViewFrame    CGRectMake(0, -80, 449, 630)

static const NSTimeInterval TIME_OUT_INTERVAL = 20;

@interface GenericWebViewBaseViewController ()
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIView *navigationViewIphone;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageIphone;
@property (weak, nonatomic) IBOutlet UIButton *backBtniPhone;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation GenericWebViewBaseViewController
{
    NSTimer * _timer;
    BOOL _showProgress;
    BOOL _useWhiteBackIcon;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.webview.scrollView.contentInsetAdjustmentBehavior  = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.view.accessibilityLabel = @"Web Browser";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigateBack:)
                                                 name:@"login_success"
                                               object:nil];
    
    if(self.requestedUrl)
    {
        
        NSURL *url = [NSURL URLWithString:self.requestedUrl];
        
        if (url==nil) {
            url=[NSURL fileURLWithPath:self.requestedUrl];
        }
    
        //URL Requst Object
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:TIME_OUT_INTERVAL];
        [request setValue:@"homestyler.com%2Fmobile" forHTTPHeaderField: @"Referer"];
        [self.webview loadRequest:request];
    }
    _showProgress = YES;
    _useWhiteBackIcon = NO;
    self.webview.alpha = 0.0;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_showProgress) {
        [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
        [ProgressPopupBaseViewController sharedInstance].colorStyle = ProgressClear;
    }
    if (self.displayPortrait) {
        //[self.backBtniPhone setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        _useWhiteBackIcon = YES;
        self.navigationView.hidden = YES;
        self.navigationViewIphone.hidden = YES;
        self.logoImage.hidden = YES;
        self.logoImageIphone.hidden = YES;
        self.webview.scrollView.scrollEnabled = NO;
        if (IS_IPAD) {
            self.webview.frame = PortraitWebViewFrame;
        }else{
            self.webview.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            [self.view sendSubviewToBack:self.webview];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_INTERVAL target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"login_success" object:nil];
    NSLog(@"dealloc - GenericWebViewBaseViewController");
}

-(void)timeOut{
    [_timer invalidate];
    _timer = nil;
    
    [self.webview stopLoading];
    [self stopProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopProgress];
    
    [UIView animateWithDuration:0.35f animations:^{
       self.webview.alpha = 1.0;
    }];
    
    if ([ConfigManager isSignInWebViewActive]) {
        NSString * html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSData * jsonData = [html dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        //parsing response
        if (dict) {
            NSDictionary *data = [dict objectForKey:@"data"];
            NSString *email = [data objectForKey:ExtenalLoginEmailField];
            if (email)
            {
                // That mean we succsessfuly login
                [self.webview setHidden:YES];
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{ExtenalLoginEmailField : email}];
                
                if ([data objectForKey:ExtenalLoginFirstNameField])
                    [userInfo setObject:[data objectForKey:ExtenalLoginFirstNameField] forKey:ExtenalLoginFirstNameField];
                
                if ([data objectForKey:ExtenalLoginLastNameField])
                    [userInfo setObject:[data objectForKey:ExtenalLoginLastNameField] forKey:ExtenalLoginLastNameField];
                
                if (webView.request && webView.request.URL && webView.request.URL.query)
                {
                    NSArray *keyValueArray = [webView.request.URL.query componentsSeparatedByString:@"="];
                    
                    if ([[keyValueArray objectAtIndex:(0)] isEqualToString:ExtenalLoginSessionKeyField])
                    {
                        [userInfo setObject:[keyValueArray objectAtIndex:(1)] forKey:ExtenalLoginSessionKeyField];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"external_login"
                                                                    object:nil
                                                                  userInfo:userInfo];
            }else{
                [self.webview setHidden:NO];
            }
        }
        else{
            [self.webview setHidden:NO];
        }
    }

    [self updateBackButtonIcon];
    [self.goBackwardBtn setEnabled:[self.webview canGoBack]];
    [self.goForwardBtn setEnabled:[self.webview canGoForward]];
}

- (void)stopProgress {
    _showProgress = NO;
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

- (void)updateBackButtonIcon {
    if (!_useWhiteBackIcon)
        return;

    _useWhiteBackIcon = NO;
    [self.backBtniPhone setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)reloadWebpage:(id)sender {
    
    [self.webview reload];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)goWebForward:(id)sender {
    
    [self.webview goForward];
    [self.goForwardBtn setEnabled:[self.webview canGoForward]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)goWebBackward:(id)sender {
    
    [self.webview goBack];
    [self.goBackwardBtn setEnabled:[self.webview canGoBack]];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (IBAction)navigateBack:(id)sender
{
    if ([[UIManager sharedInstance] isRedirectToLogin]) {
        [[UIManager sharedInstance] setIsRedirectToLogin:NO];
    }
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURL *externalLoginURL;
    if ([[ConfigManager sharedInstance] externalLoginUrl])
        externalLoginURL = [NSURL URLWithString:[[ConfigManager sharedInstance] externalLoginUrl]];
    
    NSString *externalLoginURLDomain;
    if ([externalLoginURL host])
        externalLoginURLDomain = [externalLoginURL host];
    
    // Once we know the domain of the external page, we search for any associated cookies
    // and remove them
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([[cookie domain] isEqualToString:externalLoginURLDomain]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    
    if (self.navigationController != nil)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.displayPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskLandscape;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////

-(BOOL)shouldAutorotate{
    return YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([request.URL.path isEqualToString:@"/facebookfollow"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbapi://"]]) {
            NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/152974201906910"];
            [[UIApplication sharedApplication] openURL:facebookURL];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/homestyler.interiordesign/"]];
        }
        return NO;
    }else if ([request.URL.path isEqualToString:@"/twitterfollow"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
            NSURL *twitterURL = [NSURL URLWithString:@"twitter://user?screen_name=homestyler"];
            [[UIApplication sharedApplication] openURL:twitterURL];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/homestyler"]];
        }
        return NO;
    }else if ([request.URL.path isEqualToString:@"/insfollow"]) {
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
            NSURL *instagramURL = [NSURL URLWithString:@"https://www.instagram.com/homestyler.interiordesign/"];
            [[UIApplication sharedApplication] openURL:instagramURL];
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.instagram.com/homestyler.interiordesign/"]];
        }
        return NO;
    }
    return YES;
}

@end
