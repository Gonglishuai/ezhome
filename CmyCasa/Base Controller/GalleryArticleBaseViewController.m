//
//  GalleryArticleBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "GalleryArticleBaseViewController.h"
#import "NSString+UrlParams.h"
#import "HSWebView.h"
#import "ProgressPopupViewController.h"
//#import "HSFlurry.h"

@interface GalleryArticleBaseViewController ()

@end

@implementation GalleryArticleBaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.webView stopLoading];
    
    if ([self.webView isLoading]) {
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc
{
    NSLog(@"dealloc - GalleryArticleBaseViewController");
}

-(void)moveToFullScreenMode
{
    self.webView.frame=CGRectMake(0, 0, 1024, 768);
    self.webView.sendReverseScrollNotification=true;
}

-(void)moveToNormalScreenMode
{
    self.webView.frame=CGRectMake(0, 51, 1024, 717);
    self.webView.sendReverseScrollNotification=false;
}


#pragma mark-
#pragma  mark Base class override

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"] || [self.webView.request URL] == nil) {
        return ;
    }
    [[ProgressPopupBaseViewController sharedInstance] startLoading :self.parentViewController];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"] || [self.webView.request URL]==nil) {
        return ;
    }
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
}

-(BOOL)getMyItemDetail{
    return [super getMyItemDetail];
}

-(void)loadUI{
    
    self.mainDesignImage=nil;
    
    //Create a URL object.
    
    NSString * _requrl = [self getItemContent];
    
    if (_requrl==nil) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:_requrl];
    
    
    if ([self.requestedURL  isEqualToString:[url absoluteString]]) {
        return;
    }
        
    //URL Requst Object
    if (self.webView.request) {
        [self.webView stopLoading];
    }
    self.requestedURL=[url absoluteString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //Load the request in the UIWebView.
    [self.webView loadRequest:request];
    [self.webView setHidden:NO];
}

-(void)clearUI
{
    [self.webView setHidden:YES];
    [self.webView stopLoading];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.itemDetail=nil;
    self.requestedURL=nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if ([[self.webView.request.URL absoluteString]isEqualToString:@"about:blank"] || [request URL]==nil ||
        [[request.URL absoluteString] isEqualToString:@"about:blank"]) {
        return YES;
    }
    NSURL *url = [request URL];
    NSString* fullurl = [url absoluteString];
    
    if ([[url query] rangeOfString:@"hsid"].location!=NSNotFound || [[url query]rangeOfString:@"ptype"].location!=NSNotFound) {
        
        NSArray * params=[[url query] componentsSeparatedByString:@"&"];
        
        NSString * pid=nil;
        NSString * ptype=nil;
        for (int i=0; i<[params count]; i++) {
            if ([[params objectAtIndex:i] rangeOfString:@"hsid"].location!=NSNotFound) {
                pid=[[[params objectAtIndex:i] componentsSeparatedByString:@"="] lastObject];
            }
            
            if ([[params objectAtIndex:i] rangeOfString:@"ptype"].location!=NSNotFound) {
                ptype=[[[params objectAtIndex:i] componentsSeparatedByString:@"="] lastObject];
            }
        }
        
        if (pid!=nil && ptype!=nil) {
            
            GalleryItemDO * item=nil;
            
            NSMutableDictionary * obj=[NSMutableDictionary dictionaryWithCapacity:0];
            
            
            [obj setObject:pid forKey:@"id"];
            if ([ptype isEqualToString:@"3d"]) {
                [obj setObject:@"1" forKey:@"type"];
                item=[[GalleryItemDO alloc] createEmptyDesignWithType:e3DItem];
            }
            if ([ptype isEqualToString:@"2d"]) {
                [obj setObject:@"2" forKey:@"type"];
                item=[[GalleryItemDO alloc] createEmptyDesignWithType:e2DItem];
            }
            
            if ([ptype isEqualToString:@"article"]) {
                [obj setObject:@"3" forKey:@"type"];
                item=[[GalleryItemDO alloc] createEmptyDesignWithType:eArticle];
            }
            
            item._id=pid;
            
            if ([ptype isEqualToString:@"external"]) {
                
                fullurl = [fullurl stringByReplacingOccurrencesOfString:@"&ptype=external" withString:@""];
                fullurl = [fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&hsid=%@",pid] withString:@""];
                fullurl = [fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"?hsid=%@",pid] withString:@""];
                fullurl = [fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"hsid=%@",pid] withString:@""];
                
                NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:fullurl];
                GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:urlWithReferer];
                [[[UIManager sharedInstance] pushDelegate]presentViewController:web animated:YES completion:nil];
                return NO;
            }
            
            if ([ptype isEqualToString:@"internal"]) {
                
                GenericWebViewBaseViewController* web =  [[UIManager sharedInstance]createGenericWebBrowser:fullurl];
                [[[UIManager sharedInstance] pushDelegate]presentViewController:web animated:YES completion:nil];
                
                return NO;
            }
            
            FullScreenBaseViewController* selgal=(FullScreenBaseViewController*) [[UIManager sharedInstance] createUniversalFullScreen:[NSArray arrayWithObjects:item, nil] withSelectedIndex:0 eventOrigin:nil ];
            
            selgal.dataSourceType=eFScreenGalleryStream;
            selgal.itemDetailsRequestNeeded=YES;
            UIViewController * cntr=[[UIManager sharedInstance] pushDelegate];
            
            dispatch_async(dispatch_get_main_queue(), ^
                           {
                               [cntr.navigationController pushViewController:selgal animated:YES];
                           });
            
            
            return NO;
        }
        
        if (pid==nil && ptype!=nil) {
            if ([ptype isEqualToString:@"external"]) {
                
                fullurl=[fullurl stringByReplacingOccurrencesOfString:@"&ptype=external" withString:@""];
                fullurl=[fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&hsid=%@",pid] withString:@""];
                fullurl=[fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"?hsid=%@",pid] withString:@""];
                
                fullurl=[fullurl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"hsid=%@",pid] withString:@""];
                
                
                NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:fullurl];
                GenericWebViewBaseViewController * web =  [[UIManager sharedInstance] createGenericWebBrowser:urlWithReferer];
                [[[UIManager sharedInstance] pushDelegate]presentViewController:web animated:YES completion:nil];
                return NO;
            }
            
            if ([ptype isEqualToString:@"internal"]) {
                
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: fullurl]
                                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                   timeoutInterval:20.0];
                
                //[request setValue:@"homestyler.com%2Fmobile" forHTTPHeaderField: @"Referer"];
                //Load the request in the UIWebView.
                [self.webView loadRequest:request];
                
                return NO;
            }
        }
    }
    
    NSString * ur=[url absoluteString];
    if([[url absoluteString] hasSuffix:@"/"]){
        ur=[ur substringToIndex:[[url absoluteString]length]-1];
    }

    //AZVNTBEHC2ACRRT
    HSMDebugLog(@"WEB URL: %@, query: %@",[fullurl lastPathComponent],[url query]);
    
    NSString *baseurl = [[NSURL URLWithString:[self getItemContent]] absoluteString];
    
    if ([baseurl hasSuffix:@"/"]) {
        baseurl=[baseurl substringToIndex:baseurl.length-1];
    }
    if ([fullurl hasSuffix:@"/"]) {
        fullurl=[fullurl substringToIndex:fullurl.length-1];
    }
    
    if ([url.absoluteString rangeOfString:[[ConfigManager sharedInstance] userProfileRedirectorLink ]].location!=NSNotFound) {
        //its user/prof redirector
        self.requestedURL=nil;
        [self performSelector:@selector(loadUI) withObject:nil afterDelay:1.0];
        return YES;
    }else{
        
        if ([fullurl  isEqualToString:baseurl] == NO) {
            fullurl = [[ConfigManager sharedInstance] updateURLStringWithReferer:fullurl];
            
            GenericWebViewBaseViewController* web = [[UIManager sharedInstance]createGenericWebBrowser:fullurl];
            [self.navigationController pushViewController:web animated:YES];
            return NO;
        }
        
    }
    return YES;
}

-(BOOL)isDesignImageLoaded{
    
    return YES;
}

-(UIImage*)getCurrentPresentingImage{
    
    return [self getYourPresentingImage];
}

-(UIImage*)getYourPresentingImage{
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self.parentViewController];
    
    NSString * url=@"";
    
    if (self.itemDetailsRequestNeeded==YES) {
        url=[self getOrigImageURL];
        
        if ([url length]==0) {
            return nil;
        }
    }else{
        url= [self getThumbnailURL];
    }

    //resize url
    url=[url generateImageURLforWidth:  1024 andHight:1024   ];

    if (self.itemDetailsPrivateURLNeeded) {
        //add timestamp
        NSString * stmp=[[[GalleryServerUtils sharedInstance] cloudCache] getRequestTimestampForDesignID:[self getItemID]];
        
        if (stmp!=nil) {
            url= [url AddUrlParameterToUrlString:stmp forKey:@"stp"];
        }
    }
    
    NSString* strID = [NSString stringWithFormat:@"%@_full", [self getItemID]];
    NSString* imagePath = [[ConfigManager sharedInstance]getStreamFilePath:strID];
        
    if ([[NSFileManager defaultManager] fileExistsAtPath: imagePath ] == NO) {
        
        //load file from url
        NSData * data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage * img=[UIImage imageWithData:data];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        return img;
    }else {
        //load file from device
        NSData * data=[NSData dataWithContentsOfFile:imagePath];
        UIImage * img=[UIImage imageWithData:data];
        [[ProgressPopupBaseViewController sharedInstance] stopLoading];

        return img;
    }
    
    return nil;
}

@end
