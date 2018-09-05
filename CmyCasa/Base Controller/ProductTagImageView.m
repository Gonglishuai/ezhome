//
//  ProductTagImageView.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/20/13.
//
//

#import "ProductTagImageView.h"
#import "ImageFetcher.h"

@implementation ProductTagImageView

+(id)getProductTagImageView{
	
    NSString * nibName = IS_IPAD ? @"ProductTagImageView" : @"iPhoneProductTagImageView";
    
	NSArray* nibContents = [[NSBundle mainBundle]
							loadNibNamed:nibName owner:self options:nil];
    ProductTagImageView * p =[nibContents objectAtIndex:0];

    p.ribonLabel.text = NSLocalizedString(@"products_catalog_new", @"NEW!");
    [p.ribonLabel sizeToFit];
    
    //Place the labelContainer in the right position
    CGRect frame = p.ribonLabelContainer.frame;
    frame.size = p.ribonLabel.frame.size;
    p.ribonLabelContainer.frame = frame;
    
    if (IS_IPAD) {
        p.ribonLabelContainer.center = CGPointMake(p.ribonImage.frame.origin.x + (p.ribonImage.frame.size.width / 2) + 10, p.ribonImage.frame.origin.y  + (p.ribonImage.frame.size.height / 2) - 10);    }
    else {
        p.ribonLabelContainer.center = CGPointMake(p.ribonImage.frame.origin.x + (p.ribonImage.frame.size.width / 2) + 5, p.ribonImage.frame.origin.y + 25 + (p.ribonImage.frame.size.height / 2) - 5);
    }
    
    p.ribonLabelContainer.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(45));

	return p;
}

- (IBAction)actionButton:(id)sender {
    if (self.actionUrl && [self.actionUrl length] != 0 && [NSURL URLWithString:self.actionUrl]!=nil) {

//        [HSFlurry logAnalyticEvent:EVENT_NAME_CLICK_BRAND_LINK withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
//                                                                                    EVENT_PARAM_VAL_LOAD_ORIGIN_HIGHLIGHT_PRODUCT,
//                                                                                EVENT_PARAM_CONTENT_ID:(self.productID)?self.productID:@"",
//                                                                                EVENT_PARAM_CONTENT_BRAND:(self.vendorName)?self.vendorName:@""}];
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:self.actionUrl];
        }
    }
}

-(void)setupProductImage:(NSString*)image andUrl:(NSString*)url prodID:(NSString *)productID vendorName:(NSString*)vendorName
{    
    self.actionUrl=url;
    self.productID = productID;
    self.vendorName = vendorName;
    if (image)
    {
        [self.productImage setImage:[UIImage imageNamed:@"place_holder.png"]];
        
        CGSize designSize = self.productImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (image)?image:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_MODELS,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.productImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.productImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              self.productImage.image = image;
                                          });
                       }
                   }];
    }
}

@end



