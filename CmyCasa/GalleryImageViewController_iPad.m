
//
//  GalleryImageViewController_iPad.m
//  CmyCasa
//
//  Created by Dor Alon on 11/8/12.
//
//

#import "GalleryImageViewController_iPad.h"

@implementation GalleryImageViewController_iPad


-(void)dealloc {
    NSLog(@"dealloc - GalleryImageViewController_iPad");
}
/*
-(void)getFullImage
{
    if (self.itemDetail.url==nil)
    {
        self.imageRequestedFromServer=NO;
        return ;
    }
    
    if ( self.imageRequestedFromServer==NO)
    {
        self.imageRequestedFromServer=YES;
        //load design image
        CGSize designSize = self.mainDesignImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.itemDetail.url)?self.itemDetail.url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : (self.mainDesignImage)?self.mainDesignImage:[UIImageView new],
                              IMAGE_FETCHER_INFO_KEY_LOAD_IMAGE_EXIF : @"YES",

                              IMAGE_FETCHER_INFO_KEY_SMARTFIT : (self.itemDetail.type==e2DItem)?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] };
        
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.mainDesignImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              self.mainDesignImage.image = image;
                                              self.imageRequestedFromServer = NO;
                                          });
                       }
                   }];
    }
}*/

- (void)toggleScreenModeAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ToggleFullScreenModeNotification object:nil];
}

@end






