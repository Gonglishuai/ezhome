//
//  ESAboutViewController.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/21.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESAboutViewController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD.h"
#import <Masonry.h>

@interface ESAboutViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *titleText;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic, strong) WKWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation ESAboutViewController

- (instancetype)initWithUrl:(NSString *)url andTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.url = url;
        self.titleText = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rightButton.hidden = YES;
    self.titleLabel.text = self.titleText;
    self.versionLabel.text = [SHAppGlobal AppGlobal_GetAppMainVersion];
    
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.backView.frame.size.width, self.backView.frame.size.height)
                                  configuration:webConfig];
    [self.backView addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView.mas_top).with.offset(0);
        make.left.equalTo(self.backView.mas_left).with.offset(0);
        make.bottom.equalTo(self.backView.mas_bottom).with.offset(0);
        make.right.equalTo(self.backView.mas_right).with.offset(0);
    }];
    self.webView.navigationDelegate = self;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.webView.frame = self.backView.bounds;
}

- (void)tapOnLeftButton:(id)sender {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
}

@end
