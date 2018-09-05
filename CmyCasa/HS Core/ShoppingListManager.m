//
//  ShoppingListManager.m
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import "ShoppingListManager.h"
#import "GalleryServerUtils.h"
#import "ShoppingListItem.h"
#import "DesignRO.h"
#import "ProductResponse.h"

@implementation ShoppingListManager

static ShoppingListManager *sharedInstance = nil;

+ (ShoppingListManager *)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ShoppingListManager alloc] init];
        
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        _currentDesignitems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setDesign:(DesignBaseClass*)design
   withComplition:(shoppingListDataAvailableBlock)notifyDataAvailableBlock
{
    _design = design;
    [_currentDesignitems removeAllObjects];
   
    [[DesignRO new] designGetPublicItem:_design._id andType:_design.type richData:NO withTimestamp:nil completionBlock:^(id serverResponse) {
        
        __block DesignGetItemResponse * response=(DesignGetItemResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [_design updateDesignItemWithResponse:response];
    
            [[DesignRO new] productListForItems:response.uniqueContentItemsIds
                                completionBlock:^(id serverResponse) {
                                    
                                    // Support for showing variations in product list
                                    // Check for every item in the shopping list if it needs to be replaced
                                    // and replace its data
                                    for (ShoppingListItem *item in ((ProductResponse*)serverResponse).shoppingListItems)
                                    {
                                        NSString *variationId = [response.productsToVariationsMapping objectForKey:item.productId];
                                        if (variationId && ![variationId isEqualToString:item.productId])
                                        {
                                            for (VariationDO *variation in item.variationsArray)
                                            {
                                                if ([variation.variationId isEqualToString:variationId])
                                                {
                                                    item.Name = variation.variationName;
                                                    item.ImageUrl = [variation.files objectForKey:@"iso"];
                                                }
                                            }
                                        }
                                    }
                                    
                                    [self updateData:serverResponse];
                    
                                    if(notifyDataAvailableBlock)
                                        notifyDataAvailableBlock(nil);
                                } failureBlock:^(NSError *error) {
                                     if(notifyDataAvailableBlock)
                                         notifyDataAvailableBlock(response.hsLocalErrorGuid);
                                } queue:dispatch_get_main_queue()];
        } else {
            if(notifyDataAvailableBlock)
                notifyDataAvailableBlock(response.hsLocalErrorGuid);
        }
        
    } failureBlock:^(NSError *error) {
        NSString * erMessage = [error localizedDescription];
        NSString * errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage
                                                                                                         withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL]
                                                                     withPrevGuid:nil];
        
        if(notifyDataAvailableBlock)
            notifyDataAvailableBlock(errguid);
    } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void) updateData:(DesignGetItemResponse*)design
{
    NSMutableArray* items = design.shoppingListItems;
    
    if (items==nil || [items isKindOfClass:[NSMutableArray class]]==false) {
        return;
    }
    [_currentDesignitems removeAllObjects];
    
    [_currentDesignitems setArray:[items copy]];
}

- (NSMutableArray*) getShoppingList {
    return _currentDesignitems;
}

+ (NSString*) loadEmailTempladeFile:(NSString*) fileName {
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString* retHTML = [NSString stringWithContentsOfFile:filePath usedEncoding:nil error:nil];
   return [retHTML stringByReplacingOccurrencesOfString:@"{IMAGES_BASE_URL}" withString:[[ConfigManager sharedInstance]SHOPPING_LIST_EMAIL_BASE_URL]];
}

- (NSString*) getShoppingListAsHTML {    
    NSString* retHTML = [ShoppingListManager loadEmailTempladeFile:@"shopping_list"];    
    NSString* seperatorHTML = [ShoppingListManager loadEmailTempladeFile:@"shopping_list_item_seperator"];
    
    //design image
    NSString *designImageUrl = _design.url;
    
    if ([[ConfigManager sharedInstance]USE_IMAGE_RESIZER_FOR_SHOPPING_LIST_EMAIL] == YES) {
        designImageUrl = [designImageUrl generateImageURLWithEncodingForWidth:516 andHight:387];
    }
    
    designImageUrl = [designImageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{images/big_photo.jpg}" withString:designImageUrl];
    
    //design url
    NSString* designUrl = [[ConfigManager sharedInstance]generateShareUrl:@"1" :_design._id];
  
//    if ([_design isPublicOrPublished]==FALSE) {
//        NSMutableDictionary * dict=[[ConfigManager sharedInstance] getMainConfigDict];
//         designUrl=[[[dict objectForKey:@"share"] objectForKey:@"url"] objectForKey:@"link"];
//        
//       
//    }
    
    designUrl = [designUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{DESIGN_URL}" withString:designUrl];    
    
    //texts
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{Design Product List}" withString:NSLocalizedString(@"shopping_list_email_title1",@"Design Product List")];
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{View design on Homestyler}" withString:NSLocalizedString(@"shopping_list_email_view_design",@"View design on Homestyler")];
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{List of products used to in the above design:}" withString:NSLocalizedString(@"shopping_list_email_title2",@"List of products used to in the above design:")];
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{Sent from Autodesk Homestyler}" withString:NSLocalizedString(@"shopping_list_email_sent_homestyler",@"Sent from Autodesk Homestyler")];
    
    
    NSString * itemsHTML = @"";
    int counter = 1;
    NSInteger productsCount = [_currentDesignitems count];
    for(ShoppingListItem* item in _currentDesignitems)
    {
        if ([item respondsToSelector:@selector(serializeAsHTML)]) {
            itemsHTML = [itemsHTML stringByAppendingString:[item serializeAsHTML]];
            if (counter++ < productsCount) {
                itemsHTML = [itemsHTML stringByAppendingString:seperatorHTML];
            }
        }
    }
    
    retHTML = [retHTML stringByReplacingOccurrencesOfString:@"{ITEMS}" withString:itemsHTML];
    return retHTML;
}

@end
