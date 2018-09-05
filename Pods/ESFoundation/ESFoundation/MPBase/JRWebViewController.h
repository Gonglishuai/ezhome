//
//  JRWebViewController.h
//  Consumer
//
//  Created by jiang on 2017/5/22.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "MPBaseViewController.h"
#import <WebKit/WebKit.h>

@interface JRWebViewController : MPBaseViewController
@property (nonatomic, strong) WKWebView *webView;

- (void)setTitle:(NSString *)title url:(NSString *)url;
- (void)setNavigationBarHidden:(BOOL)hidden hasBackButton:(BOOL)hasBack;
- (void)hideRefreshStatus;

@end
