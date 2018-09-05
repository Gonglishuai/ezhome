//
//  ESWebTableViewCell.m
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESWebTableViewCell.h"

#import "JRKeychain.h"
#import <Masonry.h>
@interface ESWebTableViewCell()<WKScriptMessageHandler, UINavigationControllerDelegate ,WKNavigationDelegate>

@property (strong, nonatomic) void(^contentSizeChangeCallBack)(CGSize);
@property (strong, nonatomic) void(^tapBlock)(NSString *);
@property(strong, nonatomic)ESWebView *webView;
@property(strong, nonatomic)UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat myHeight;
@property (copy, nonatomic) NSString *myurl;
@end

@implementation ESWebTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setupFrame];
}

- (void)setupFrame {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.contentView addSubview:_scrollView];
    
    _webView = [[ESWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _webView.scrollView.scrollEnabled = NO;
    WS(weakSelf)
    [self.scrollView addSubview:_webView];
    __weak __block __typeof(&*_webView) b_webView = _webView;
    __weak __block __typeof(&*_scrollView) b_scrollView = _scrollView;
    [_webView setContentSizeCallBack:^(CGSize size) {
        SHLog(@"-------------\n %f \n-------------", size.height);
        if (weakSelf.myHeight != size.height && weakSelf.myHeight > 0) {
            weakSelf.myHeight = size.height;
            [b_scrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(size.height));
                
            }];
            b_webView.frame = CGRectMake(0, 0, size.width, size.height);
            b_webView.scrollView.contentSize = size;
            [b_webView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(size.height));
                
            }];
            if (weakSelf.contentSizeChangeCallBack) {
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2/*延迟执行时间*/ * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                    if ((!weakSelf.webView.isLoading) && (weakSelf.myHeight == size.height)) {
                        weakSelf.contentSizeChangeCallBack(size);
                    }
                });
            }
        } else {
            weakSelf.myHeight = size.height;
        }
        
    }];
    _webView.navigationDelegate = self;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.contentView.mas_top).with.offset(0);
        make.left.equalTo(weakSelf.contentView.mas_left).with.offset(0);
        make.bottom.equalTo(weakSelf.contentView.mas_bottom).with.offset(0);
        make.right.equalTo(weakSelf.contentView.mas_right).with.offset(0);
        make.height.greaterThanOrEqualTo(@(SCREEN_HEIGHT));
    }];
    
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(weakSelf.scrollView.mas_width);
        make.height.equalTo(weakSelf.scrollView.mas_height);
        make.height.greaterThanOrEqualTo(@(SCREEN_HEIGHT));
    }];
    [self addCookie];
    
    
    
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUrl:(NSString *)url ContentSizeCallBack:(void(^)(CGSize))block  tapBlock:(void(^)(NSString *))tapBlock {
    if ([_myurl isEqualToString:url]) {
        
    } else {
        _myurl = url;
        [self addCookie];
        NSString *requestUrl = [NSString stringWithFormat:@"%@?resource=App", url];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
        [_webView loadRequest:request];
        
    }
    _contentSizeChangeCallBack = block;
    _tapBlock = tapBlock;
    
}

- (void)addCookie {
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeXToken] isEqualToString:@""]) {
        NSString *tkCookieStr = [NSString stringWithFormat:@"token=%@", [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];
        NSString *tkScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", tkCookieStr];
        WKUserScript *tkUserScript = [[WKUserScript alloc] initWithSource:tkScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:tkUserScript];
    }
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodeType] isEqualToString:@""]) {
        NSString *memberTypeCookieStr = [NSString stringWithFormat:@"member_type=%@", [JRKeychain loadSingleUserInfo:UserInfoCodeType]];
        NSString *memberTypeScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", memberTypeCookieStr];
        WKUserScript *memberTypeUserScript = [[WKUserScript alloc] initWithSource:memberTypeScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:memberTypeUserScript];
    }
    if (![[JRKeychain loadSingleUserInfo:UserInfoCodePhone] isEqualToString:@""]) {
        NSString *phoneCookieStr = [NSString stringWithFormat:@"phone=%@", [JRKeychain loadSingleUserInfo:UserInfoCodePhone]];
        NSString *phoneScriptStr = [NSString stringWithFormat:@"document.cookie='%@'", phoneCookieStr];
        WKUserScript *phoneUserScript = [[WKUserScript alloc] initWithSource:phoneScriptStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [_webView.configuration.userContentController addUserScript:phoneUserScript];
    }
}

#pragma mark -- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURL *redirectURL = navigationAction.request.URL;
    
    NSString *query = [NSString stringWithFormat:@"%@", redirectURL];
    

    if ([query containsString:@"operationType"] || [query containsString:@"operationtype"]) {
        if ([query containsString:@"H5"]) {
            NSArray *queryArray = [query componentsSeparatedByString:@"??"];
            NSString *urlStr = [NSString stringWithFormat:@"%@", queryArray.firstObject];
            if (_tapBlock) {
                _tapBlock(urlStr);
            }
        } else {
            NSArray *queryArray = [query componentsSeparatedByString:@"??"];
            NSString *urlStr = [NSString stringWithFormat:@"%@", queryArray.lastObject];
            if (_tapBlock) {
                _tapBlock(urlStr);
            }
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    if (webView.isLoading) {
//        return;
//    }
//}



@end
