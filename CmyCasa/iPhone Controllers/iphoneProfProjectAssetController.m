//
//  ProfProjectAssetController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/2/13.
//
//

#import "iphoneProfProjectAssetController.h"
#import "ImageFetcher.h"

@interface iphoneProfProjectAssetController ()

@end

@implementation iphoneProfProjectAssetController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (IBAction)chooseDesignAction:(id)sender {
    
    if (self.delegate) {
        [self.delegate designSelected:self.asset];
    }
}

-(void)initWithAssset:(ProfProjectAssetDO*)_sset{
   
    self.isAssetLoaded=YES;
    self.asset=_sset;
    
    self.projectTitle.text=_sset.title;
     NSLog(@"%@",self.view);
    
    NSString * url=self.asset.url;

    [self.activity startAnimating];
    self.assetImage.image = [UIImage imageNamed:@"place_holder.png"];

    //load design image
    CGSize designSize = CGSizeMake(290, 296);
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (url)?url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.assetImage};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.assetImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (image) {
                                              self.assetImage.image = image;
                                          }
                                        
                                          [self.activity stopAnimating];
                                      });
                   }
               }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [self setAssetImage:nil];
    [self setActivity:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setProjectTitle:nil];
}

@end
