//
//  ProductInfoTitleSwappableCell.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 11/18/14.
//
//

#import "ProductSwappableVariationCell.h"
#import "SwappableVariationView.h"
#import "VariationDO.h"
#import "ProductVendorDO.h"
#import "ImageFetcher.h"

@implementation SwappableCellVariationData

-(instancetype)initWithEntity:(Entity*)entity shoppingListItem:(ProductDO*)shoppingListItem{
    self = [super init];
    if (self) {
        _entity = entity;
        _productItem = (ShoppingListItem*)shoppingListItem;
    }
    return self;
}

@end


@implementation ProductSwappableVariationCell

#define DELTA_SWATCH_SIZE 4

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.assemblyProductInformationButton setTitle:NSLocalizedString(@"production_information", @"") forState:UIControlStateNormal];
    [self.assemblyProductInformationButton setHidden:TRUE];
}

-(void)generateSwappableVariationViews:(NSArray*)swappableVariation
                 withSelectedVariation:(NSString*)selectedVariation
{
    RETURN_VOID_ON_NIL(self.dataForCell);
    RETURN_VOID_ON_NIL(swappableVariation);
    RETURN_VOID_ON_NIL(selectedVariation);
    
    if ([swappableVariation count] == 0)
        return;
    
    //swatches scroller
    int totalWidth = 0;
    
    if (!self.swappableVariationViewsArray)
    {
        self.swappableVariationViewsArray = [[NSMutableArray alloc] init];
    }
    else
    {
        //cleanup views from scroll view
        for (UIView * swapVariation in self.swappableVariationViewsArray) {
            [swapVariation removeFromSuperview];
        }
        
        [self.swappableVariationViewsArray removeAllObjects];
    }
    
    SwappableVariationView * svView = nil;
    
    // Set label based on quantity of variations
    NSString *titleStringFormat = NSLocalizedString(@"choose_variation", @"Choose Variation (%d):");
    NSString *titleLabel = [NSString stringWithFormat:titleStringFormat, (int)[swappableVariation count]];
    [self.variationTitleLabel setText:titleLabel];
    
    for (int i = 0; i < [swappableVariation count]; ++i)
    {
        VariationDO *colorDo = [swappableVariation objectAtIndex:i];
        
        if (!colorDo && !([colorDo.files count] > 0)) {
            return;
        }
        
        svView = [SwappableVariationView getSwappableVriationView];
        if (colorDo.files) {
            NSString * imageUrl = [colorDo.files objectForKey:@"iso"];
            if (imageUrl) {
                [svView setupSwappabelVariationImage:imageUrl];
            }
            
            [svView setSwappableVariationViewDelegate:self];
            [svView setTag:i];
            
            //add to view array
            [self.swappableVariationViewsArray addObject:svView];
            
            svView.frame = CGRectMake(i * (svView.frame.size.width + DELTA_SWATCH_SIZE), 0, svView.frame.size.width, svView.frame.size.height);
            
            [self.swappableVariationScrollView addSubview:svView];
            
            if (selectedVariation && [selectedVariation isEqualToString:colorDo.variationId])
            {
                [self setSwappableVariationViewAsSelectedAtIndex:[NSNumber numberWithInt:i]];
                [self.assemblyProductTitleLabel setText:colorDo.variationName];
            }
        }
    }
    
    totalWidth = (int)[swappableVariation count] * (svView.frame.size.width + DELTA_SWATCH_SIZE);
    [self.swappableVariationScrollView setContentSize:CGSizeMake(totalWidth, svView.frame.size.height)];

}

- (void)setSwappableVariationViewAsSelectedAtIndex:(NSNumber*)index
{
    SwappableVariationView * view = [self.swappableVariationViewsArray objectAtIndex:[index intValue]];

    
    if (view) {
        [view setBackgroundColor:[UIColor colorWithRed:(0/255) green:(76/255) blue:(151/255) alpha:1]];
    }
    
    // If an image is already loaded, perform a fast image change for variation
    if (view.imageView.image && self.assemblyProductImageView) {
        [self.assemblyProductImageView setImage:view.imageView.image];
        return;
    }

    VariationDO *variation = (VariationDO*)[self.swappableVariationArray objectAtIndex:[index intValue]];
    NSString *imageURL = [variation.files objectForKey:@"iso"];
    
    if (imageURL && self.assemblyProductImageView)
    {
        CGSize designSize =self.assemblyProductImageView.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (imageURL) ? imageURL : @"",
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.assemblyProductImageView};
        
        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic
                                                 andCompletionBlock:^(UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.assemblyProductImageView];
                       
                       if (currentUid == uid)
                       {
                           DISPATCH_ASYNC_ON_MAIN_QUEUE([self.assemblyProductImageView setImage:image];);
                       }
                   }];
    }
    
    // border color for selected variation
    [view setBackgroundColor:[UIColor colorWithRed:(0/255) green:(76/255) blue:(151/255) alpha:1]];
}

-(void)swappableVariationClickedWithIndex:(NSNumber*)index
{
    RETURN_VOID_ON_NIL(self.dataForCell);
    RETURN_VOID_ON_NIL(self.dataForCell.productItem);
    
    // deselect all cells
    for (SwappableVariationView * view in self.swappableVariationViewsArray) {
        // border color for not selected variation
        [view setBackgroundColor:[UIColor lightGrayColor]];
    }
    
    // select the current selected cell
    [self setSwappableVariationViewAsSelectedAtIndex:index];
    
    if ([self.swappableVariationArray count] > 0) {
        VariationDO *chosenVariation = [self.swappableVariationArray objectAtIndex:[index integerValue]];
        
        if (chosenVariation)
            [self.assemblyProductTitleLabel setText:chosenVariation.variationName];
        
        if (self.productSwappableVariationCellDelegate && [self.productSwappableVariationCellDelegate respondsToSelector:@selector(swapEntity:withVariation:)])
        {
            [self.productSwappableVariationCellDelegate swapEntity:self.dataForCell.entity
                                                     withVariation:chosenVariation];
        }
    }
}

// goto product site via self.genericWebViewDelegate
- (IBAction)assemblyProductInformationPressed:(id)sender
{
    RETURN_VOID_ON_NIL(self.dataForCell);
    RETURN_VOID_ON_NIL(self.dataForCell.productItem);
    RETURN_VOID_ON_NIL(self.dataForCell.productItem.productVendor);
    
    // Need to update URL sent to delegate for presentation
    if ([self.genericWebViewDelegate respondsToSelector:@selector(openInteralWebViewWithUrl:)]) {
        [self.genericWebViewDelegate performSelector:@selector(openInteralWebViewWithUrl:) withObject:self.dataForCell.productItem.productVendor.vendorProductUrl];
    }
}

@end
