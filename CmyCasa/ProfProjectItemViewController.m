//
//  ProfProjectItemViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/13/13.
//
//

#import "ProfProjectItemViewController.h"
#import "ImageFetcher.h"

@interface ProfProjectItemViewController ()

@end

@implementation ProfProjectItemViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)loadImageForURL:(NSString*)imageUrl
{
    [self.activity startAnimating];
    
    //load design image
    CGSize designSize = self.view.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (imageUrl)?imageUrl:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.projectImage,
                          IMAGE_FETCHER_INFO_KEY_SMARTFIT : [NSNumber numberWithBool:NO]};

    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.projectImage];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          
                                          self.projectImage.image = image;
                                          [self.activity stopAnimating];
                                      });
                   }
               }];
}

@end
