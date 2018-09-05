//
//  GenericWebViewBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <UIKit/UIKit.h>

@interface GenericWebViewBaseViewController : UIViewController<UIWebViewDelegate>

- (IBAction)reloadWebpage:(id)sender;
- (IBAction)goWebForward:(id)sender;
- (IBAction)goWebBackward:(id)sender;
- (IBAction)navigateBack:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *goForwardBtn;
@property (weak, nonatomic) IBOutlet UIButton *goBackwardBtn;
@property (weak, nonatomic) IBOutlet UIWebView * webview;
@property (nonatomic, strong) NSString * requestedUrl;
@property (nonatomic) BOOL displayPortrait;
@end
