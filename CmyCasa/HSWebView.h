//
//  HSWebView.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/2/13.
//
//

#import <UIKit/UIKit.h>

static NSString * ArticleWebViewScrollDownNotification=@"ArticleWebViewScrollDownNotification";

static NSString * ArticleWebViewScrollUpNotification=@"ArticleWebViewScrollUpNotification";

static NSString * ToggleFullScreenModeNotification=@"ToggleFullScreenModeNotification";

static NSString * DoubleTapGestureDetectedNotification=@"DoubleTapGestureDetectedNotification";

@interface HSWebView : UIWebView<UIScrollViewDelegate>


@property(nonatomic)BOOL sendReverseScrollNotification;

-(void)updateOffset:(int)offset;
@end
