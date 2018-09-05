//
//  ExternalLoginViewController.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/26/14.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const ExtenalLoginExternalIdField;
FOUNDATION_EXPORT NSString *const ExtenalLoginEmailField;
FOUNDATION_EXPORT NSString *const ExtenalLoginFirstNameField;
FOUNDATION_EXPORT NSString *const ExtenalLoginLastNameField;
FOUNDATION_EXPORT NSString *const ExtenalLoginSessionKeyField;

@interface ExternalLoginViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView * webview;
@property (weak, nonatomic) IBOutlet UIView * bgView;
@property (weak, nonatomic) IBOutlet UIView * containerView;
@property (nonatomic, assign) NSString * requestedUrl;
@property (nonatomic, assign) BOOL isViewAddedAsChild;


+(void)showExternalLogin:(UIViewController*)viewController;
-(void)startBgAnimation;
@end
