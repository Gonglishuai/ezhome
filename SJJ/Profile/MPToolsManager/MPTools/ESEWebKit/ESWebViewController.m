
#import "ESWebViewController.h"
#import <WebKit/WebKit.h>

@interface ESWebViewController ()<WKUIDelegate, WKNavigationDelegate>

@end

@implementation ESWebViewController
{
    NSString *_title;
    NSString *_url;
    WKWebView *_webView;
}

- (instancetype)initWithTitle:(NSString *)title
                          url:(NSString *)url
{
    self = [super init];
    if (self)
    {
        if ([title isKindOfClass:[NSString class]])
        {
            _title = title;
        }
        
        if ([url isKindOfClass:[NSString class]])
        {
            _url = url;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.rightButton.hidden = YES;
    self.titleLabel.text = _title;
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(
                                                           0,
                                                           NAVBAR_HEIGHT,
                                                           SCREEN_WIDTH,
                                                           SCREEN_HEIGHT - NAVBAR_HEIGHT
                                                           )
                                  configuration:webConfig];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    if (_url)
    {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        [_webView loadRequest:request];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    __weak ESWebViewController *weakSelf = self;
    [webView evaluateJavaScript:(@"document.title") completionHandler:^(NSString* result, NSError * _Nullable error) {
        NSString *title = [NSString stringWithFormat:@"%@", result ? result : (weakSelf.title ? weakSelf.title : @"")];
        weakSelf.titleLabel.text = title;
    }];
}

#pragma mark - Super Methods
- (void)tapOnLeftButton:(id)sender
{
    if (self.navigationController.topViewController == self)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
