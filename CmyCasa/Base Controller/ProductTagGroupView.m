//
//  ProductTagGroupView.m
//  Homestyler
//
//  Created by Dan Baharir on 2/16/15.
//
//

#import "ProductTagGroupView.h"
#import "ProductTagImageView.h"
#import "ImageFetcher.h"


@implementation ProductTagGroupView

-(void)setProductInView:(ProductDO *)product
{
    self.product = product;
    self.layer.borderWidth = 0.9;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    //init product information availbale before fetching additional data (images etc.)
    [_titleLabel setText:product.Name];
    
    //set product site url
     self.actionUrl = [product getVendorSiteAtIndex:0];
  
    //get and set the product image
    if ([product.productImages count] > 0) {
        NSString * imageUrl = [product.productImages objectAtIndex:0];
        
        CGSize designSize = self.imageView.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: imageUrl,
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.imageView};
        
        [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta){
            NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.imageView];
            
            if (currentUid == uid){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        [self.imageView setHidden:NO];
                        [self.imageView setImage:image];
                    }else{
                        [self.imageView setHidden:YES];
                    }
                });
            }
        }];
    }
}

- (IBAction)actionButtonClicked:(id)sender
{
    if (self.actionUrl) {
        
        if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
            [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:self.actionUrl];
        }
    }
}

- (IBAction)swapEntityClicked:(id)sender
{
    if ([self.swappableProductDelegate respondsToSelector:@selector(swappableProduct:)])
    {
        NSLog(@"Swap with productId: %@", [self.product productId]);

        [self.swappableProductDelegate performSelector:@selector(swappableProduct:) withObject:self.product];
        [self setSelected];
    }
}

-(void)setDeselect
{
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;

}

-(void)setSelected
{
    for (UIView *view in self.superview.subviews)
    {
        if ([view isKindOfClass:[ProductTagGroupView class]])
        {
           [(ProductTagGroupView *)view setDeselect];
        }
    }
    // selected family color
    self.layer.borderColor = [UIColor blackColor].CGColor;
}



@end
