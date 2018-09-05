//
//  ExternalLoginViewController.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/26/14.
//
//

#import "ExternalLoginViewController.h"

NSString *const ExtenalLoginExternalIdField = @"identifier";
NSString *const ExtenalLoginEmailField = @"email";
NSString *const ExtenalLoginFirstNameField = @"firstname";
NSString *const ExtenalLoginLastNameField = @"lastname";
NSString *const ExtenalLoginSessionKeyField = @"sessionKey";

@interface ExternalLoginViewController ()

@end

@implementation ExternalLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeExternalLoginView)
                                                 name:@"login_success"
                                               object:nil];
    
    self.view.accessibilityLabel = @"Web Browser";
    
    self.webview.scrollView.bounces = NO;
    
    RETURN_VOID_ON_NIL(self.requestedUrl);

    NSURL *url = [NSURL URLWithString: self.requestedUrl];
    
    if (url) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        [request setValue:@"homestyler.com%2Fmobile" forHTTPHeaderField: @"Referer"];
        [self.webview loadRequest:request];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"login_success" object:nil];
    NSLog(@"dealloc - ExternalLoginViewController");
}

- (void)webViewDidStartLoad:(UIWebView *)webView;{
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.webview.request];
    NSLog(@"webViewDidStartLoad : %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
    
    NSURLRequest * request = self.webview.request;
    if ([[[request URL] absoluteString] isEqualToString:self.requestedUrl]) {
        [self.containerView setHidden:YES];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{ExtenalLoginEmailField : email}];
                
                if ([data objectForKey:ExtenalLoginFirstNameField])
                    [userInfo setObject:[data objectForKey:ExtenalLoginFirstNameField]
                                 forKey:ExtenalLoginFirstNameField];
                
                if ([data objectForKey:ExtenalLoginLastNameField])
                    [userInfo setObject:[data objectForKey:ExtenalLoginLastNameField]
                                 forKey:ExtenalLoginLastNameField];
                
                if (webView.request && webView.request.URL && webView.request.URL.query)
                {
                    NSArray *keyValueArray = [webView.request.URL.query componentsSeparatedByString:@"="];
                    
                    if ([[keyValueArray objectAtIndex:(0)] isEqualToString:ExtenalLoginSessionKeyField])
                    {
                        [userInfo setObject:[keyValueArray objectAtIndex:(1)] forKey:ExtenalLoginSessionKeyField];
                    }
                }
                
                [self clearSessionCookies];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"external_login"
                                                                    object:nil
                                                                  userInfo:userInfo];
            }else{
                [self.containerView setHidden:NO];
            }
        }else{
            [self.containerView setHidden:NO];
        }
        
        [self.webview.scrollView flashScrollIndicators];
    }
}


- (void)clearSessionCookies
{
    RETURN_VOID_ON_NIL([[ConfigManager sharedInstance] externalLoginUrl]);
    NSURL *externalLoginURL = [NSURL URLWithString:[[ConfigManager sharedInstance] externalLoginUrl]];
    RETURN_VOID_ON_NIL(externalLoginURL);
    NSString *externalLoginURLDomain = [externalLoginURL host];
    RETURN_VOID_ON_NIL(externalLoginURLDomain);
    
    // Once we know the domain of the external page, we search for any associated cookies
    // and remove them
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([[cookie domain] isEqualToString:externalLoginURLDomain]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)closeExternalLoginView
{
    [self.bgView setAlpha:0.0];
    
    if (self.isViewAddedAsChild) {
        [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            // this animation is for delay only
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
        
    }else{
        
        if (self.navigationController != nil)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (IBAction)navigateBack:(id)sender
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    // Clean session cookies such that the user browsing is in memory-less mode
    [self clearSessionCookies];
    
    // rotate orientation to landscape before dismissing the viewController
    if (sender)
    {
        float delayTime = 0.4;
        if (UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[[UIDevice currentDevice] orientation]))
            delayTime = 0.01;
        
        if ([self respondsToSelector:@selector(setLandscapeOrientation)]) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self setLandscapeOrientation];
            });
        }
        [self performSelector:@selector(navigateBack:) withObject:nil afterDelay:delayTime];
    }
    else
    {
        [self closeExternalLoginView];
    }
}

-(void)setLandscapeOrientation
{
    if (UIInterfaceOrientationIsPortrait((UIInterfaceOrientation)[[UIDevice currentDevice] orientation]) || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown)
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

-(BOOL)shouldAutorotate{
    return YES;
}

-(void)startBgAnimation{
    [UIView animateWithDuration:0.5 animations:^{
        [self.bgView setAlpha:0.5];
    }];
}

+(void)showExternalLogin:(UIViewController*)viewController{
    
    NSArray * vcArray = [viewController childViewControllers];
    for (UIViewController *vc in vcArray) {
        if ([vc isKindOfClass:[ExternalLoginViewController class]]) {
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
   
    ExternalLoginViewController * elvc = [[ExternalLoginViewController alloc] initWithNibName:@"ExternalLoginViewController" bundle:nil];
    
    [viewController addChildViewController:elvc];
    [elvc setRequestedUrl:[[ConfigManager sharedInstance] externalLoginUrl]];
    elvc.isViewAddedAsChild = YES;
    elvc.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [viewController.view addSubview:elvc.view];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         elvc.view.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [elvc startBgAnimation];
                     }];
}

@end
