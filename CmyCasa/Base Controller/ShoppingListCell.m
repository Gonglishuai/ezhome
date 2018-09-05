//
//  ShoppingListCell.m
//  Homestyler
//
//  Created by Dor Alon on 6/15/13.
//
//

#import "ShoppingListCell.h"
#import "ShoppingListItem.h"
#import "ImageFetcher.h"
#import "ProductVendorDO.h"
#import "UIView+NUI.h"

@implementation ShoppingListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.gotoWebLabel.text = NSLocalizedString(@"shopping_list_go_to_website", @"Go to Website");
    }
    return self;
}

-(void)initShoppingListCell:(ShoppingListItem*)item{
    
    if (item.ImageUrl!=nil && [item.ImageUrl length]>0)
    {
        
        //load design image
        CGSize designSize = self.image.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (item.ImageUrl)?item.ImageUrl:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.image};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.image];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              
                                              self.image.image = image;
                                              
                                          });
                       }
                   }];
        
    }
    
    if ((item.productVendor.vendorImageUrl!=nil && [item.productVendor.vendorImageUrl length]>0) ||
        (item.vendorLogoUrl!=nil && [item.vendorLogoUrl length]>0) ) {
        
        NSString* url = @"";
        if (item.productVendor.vendorImageUrl!=nil && [item.productVendor.vendorImageUrl length]>0) {
            url = item.productVendor.vendorImageUrl;
        }
        if (item.vendorLogoUrl!=nil && [item.vendorLogoUrl length]>0) {
            url = item.vendorLogoUrl;
        }
        CGSize  designSize = self.vendorImage.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: url,
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.vendorImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.vendorImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              
                                              self.vendorImage.image = image;
                                              
                                          });
                       }
                   }];
        
    }
    
    self.image.accessibilityLabel = [NSString stringWithFormat:@"img_product_%@",item.Name];
    self.vendorImage.accessibilityLabel = [NSString stringWithFormat:@"img_vendor_%@",item.Name];
    self.nameLabel.accessibilityLabel = [NSString stringWithFormat:@"lbl_name_%@",item.Name];
    self.gotoWebLabel.accessibilityLabel = [NSString stringWithFormat:@"lbl_Website_%@",item.Name];
}

@end
