//
//  CatalogCell.m
//  CmyCasa
//
//  Created by Dor Alon on 2/10/13.
//
//

#import "CatalogCell.h"
#import "CatalogCategoryDO.h"
#import "UIImage+SafeFileLoading.m"
#import "ImageFetcher.h"
#import "UILabel+NUI.h"
#import "ModelsHandler.h"
#import "WishListProductDO.h"

@implementation CatalogCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    self.catalogTitle.highlighted = selected;
    self.catalogTitle.highlightedTextColor = [UIColor colorWithRed:(255/255.0) green:(204/255.0) blue:(0/255.0) alpha:1];
    [super setSelected:selected animated:animated];
    
//    self.selectionBackground.hidden=!selected;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.productImage.image = nil;
}

// Decode a percent escape encoded string.
- (NSString*) decodeFromPercentEscapeString:(NSString *) string {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

-(void)updateWithWishList:(WishListProductDO*)wishlist  isRoot:(BOOL)isRoot
{
    [self.catalogTitle setText:[self decodeFromPercentEscapeString:wishlist.productName]];
}

-(void)updateWithCategory:(CatalogCategoryDO*)category  isRoot:(BOOL)isRoot
{
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        self.catalogTitle.text = category.categoryName;
        self.catalogTitle.textColor = [UIColor colorWithRed:0.3686 green:0.3686 blue:0.3686 alpha:1];
        
        
        if ([[UserManager sharedInstance] checkIfModeller] && category.categoryStatus != nil && [category.categoryStatus intValue] != 1) {
            
            switch ([category.categoryStatus intValue]) {
                case 0: {
                    self.catalogTitle.text = [@"[Deleted] " stringByAppendingString:category.categoryName];
                    self.catalogTitle.textColor = [UIColor blackColor];
                }
                    break;
                case 2: {
                    self.catalogTitle.text = [@"[Hidden] " stringByAppendingString:category.categoryName];
                    self.catalogTitle.textColor = [UIColor orangeColor];
                }
                    break;
                case 3: {
                    self.catalogTitle.text = [@"[Private] " stringByAppendingString:category.categoryName];
                    self.catalogTitle.textColor = [UIColor redColor];
                }
                    break;
                default:
                    break;
            }
            
        }
    });
    
    // check if we need to display catalog icons in cell
    if (![ConfigManager isCatalogIconsActive])
    {
        self.productImage.hidden = YES;
        [self.catalogTitle setFrame:CGRectMake(self.catalogTitle.frame.origin.x, self.productImage.frame.origin.y, self.catalogTitle.frame.size.width, self.catalogTitle.frame.size.height)];
    }
    else
    {
        self.productImage.hidden = NO;
        [self.catalogTitle setFrame:CGRectMake(self.productImage.frame.size.width + 10, self.productImage.frame.origin.y, self.catalogTitle.frame.size.width, self.catalogTitle.frame.size.height)];
    }

    
    if (isRoot) {
        NSString* url =[category getCategoryIconUrl:IS_RETINA()];
        
        CGSize designSize = self.productImage.frame.size;
        
        // Adapt for retina sizes
        designSize.width = designSize.width;
        designSize.height = designSize.height;
        
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (url)?url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.productImage};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.productImage];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image) {
                                                  self.productImage.image = image;
                                              }
                                              
                                          });
                       }
                   }];
    }
}

@end
