//
//  ShoppingListItem.m
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import "ShoppingListItem.h"
#import "ModelsHandler.h"
#import "ShoppingListManager.h"
#import "RetailerDO.h"
#import "ProductVendorDO.h"

@implementation ShoppingListItem

- (NSString *) serializeAsHTML {
    
    NSString *productImageUrl = self.ImageUrl;
    if ([[ConfigManager sharedInstance]USE_IMAGE_RESIZER_FOR_SHOPPING_LIST_EMAIL] == YES) {
        productImageUrl = [productImageUrl generateImageURLWithEncodingForWidth:183 andHight:185];
    }
    
    if (self.IsGeneric) {
        NSString* retHTML = [ShoppingListManager loadEmailTempladeFile:@"shopping_list_item_generic"]; 
        retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{PRODUCT_NAME}" withString:self.Name];
        retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{PRODUCT_IMAGE}" withString:productImageUrl];
        return retHTML;
    }else {
        NSString* retHTML = [ShoppingListManager loadEmailTempladeFile:@"shopping_list_item"];
        retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{PRODUCT_NAME}" withString:self.Name];
                
        NSString* by = NSLocalizedString(@"shopping_list_by", @"by");
        NSString* vendorName = [NSString stringWithFormat:@"%@ %@",by, self.productVendor.vendorName];
        retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{VENDOR_NAME}" withString:vendorName];
        retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{GOTO_WEB_TEXT}" withString:NSLocalizedString(@"shopping_list_go_to_website",@"Go to Website")];
       
        NSString* escapedVendorProductUrl = [self.productVendor.vendorProductUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       
        if (escapedVendorProductUrl) {
          retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{VENDOR_PRODUCT_URL}" withString:escapedVendorProductUrl];  
        }
        
        NSString* escapedVendorImageUrl = [self.productVendor.vendorImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (escapedVendorImageUrl) {
            retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{VENDOR_IMAGE}" withString:escapedVendorImageUrl];
            
        }
        
        if (productImageUrl) {
               retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{PRODUCT_IMAGE}" withString:productImageUrl];
        }
     
        return retHTML;
    }
}

@end
