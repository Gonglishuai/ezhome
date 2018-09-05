//
//  ESWebView.h
//  Consumer
//
//  Created by jiang on 2017/8/15.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface ESWebView : WKWebView
- (void)setContentSizeCallBack:(void(^)(CGSize))block;
@end
