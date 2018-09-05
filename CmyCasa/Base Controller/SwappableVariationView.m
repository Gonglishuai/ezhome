//
//  SwappableVariationView.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/23/14.
//
//

#import "SwappableVariationView.h"
#import "ImageFetcher.h"

@implementation SwappableVariationView


+(id)getSwappableVriationView
{
    NSString * nibName = IS_IPAD ? @"SwappableVariationView_iPad" : @"SwappableVariationView_iPhone";
    NSArray* nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    SwappableVariationView *view = [nibContents objectAtIndex:0];

    return view;
}

-(void)setupSwappabelVariationImage:(NSString*)imageURL
{
    if (imageURL)
    {
        CGSize designSize = self.imageView.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (imageURL) ? imageURL : @"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.imageView};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic
                                                 andCompletionBlock:^(UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                                            {
                                                NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.imageView];
                                                
                                                if (currentUid == uid)
                                                {
                                                    DISPATCH_ASYNC_ON_MAIN_QUEUE(self.imageView.image = image;);
                                                }
                                            }];
    }
}

- (IBAction)swatchPressed:(id)sender
{
    if ([self.swappableVariationViewDelegate respondsToSelector:@selector(swappableVariationClickedWithIndex:)])
    {
        NSInteger index = self.tag;
        [self.swappableVariationViewDelegate performSelector:@selector(swappableVariationClickedWithIndex:) withObject:[NSNumber numberWithInteger:index]];
    }
}

@end
