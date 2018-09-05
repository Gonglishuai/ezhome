//
//  GalleryArticleBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "GalleryItemBaseViewController.h"

@class HSWebView;

@interface GalleryArticleBaseViewController : GalleryItemBaseViewController

@property (weak, nonatomic) IBOutlet HSWebView *webView;
@property(nonatomic)NSString * requestedURL;

-(void)moveToFullScreenMode;
-(void)moveToNormalScreenMode;

@end
