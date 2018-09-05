//
//  CategoryCell_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import "CategoryCell_iPhone.h"
#import "CatalogCategoryDO.h"
#import "ImageFetcher.h"
#import "ModelsHandler.h"


@implementation CategoryCell_iPhone

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    self.selectionBackground.hidden = !selected;
    self.catTitle.highlightedTextColor = [UIColor colorWithRed:(255/255.0) green:(204/255.0) blue:(0/255.0) alpha:1];
    self.catTitle.highlighted = selected;
    // Configure the view for the selected state
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    self.categoryIcon.image = nil;
}

// Decode a percent escape encoded string.
- (NSString*) decodeFromPercentEscapeString:(NSString *) string {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

-(void)updateWithWishList:(WishListProductDO*)wishList isRoot:(BOOL)isRoot{
    
    self.catTitle.text = [self decodeFromPercentEscapeString:wishList.productName];
    self.catTitle.textAlignment = NSTextAlignmentLeft;
}

-(void)updateWithCategory:(CatalogCategoryDO*)category isRoot:(BOOL)isRoot{
    
    self.catTitle.text = category.categoryName;
    
    // check if we need to display catalog icons in cell
    if (![ConfigManager isCatalogIconsActive])
    {
        self.categoryIcon.hidden = YES;
        [self.catTitle setFrame:CGRectMake(10, self.categoryIcon.frame.origin.y, self.catTitle.frame.size.width, self.catTitle.frame.size.height)];
    }
    else
    {
        self.categoryIcon.hidden = NO;
        [self.catTitle setFrame:CGRectMake(self.categoryIcon.frame.size.width + 10, self.categoryIcon.frame.origin.y, self.catTitle.frame.size.width, self.catTitle.frame.size.height)];
    }
    
    
    if (isRoot) {
        NSString* url =[category getCategoryIconUrl:IS_RETINA()];
        
        CGSize designSize = self.categoryIcon.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (url)?url:@"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.categoryIcon};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary * imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.categoryIcon];
                       
                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if (image) {
                                                  self.categoryIcon.image = image;
                                              }
                                          });
                       }
                   }];
    }

}


@end
