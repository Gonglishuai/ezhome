//
//  DesignGetItemResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/12/13.
//
//

#import "DesignGetItemResponse.h"
#import "ModelsHandler.h"

@implementation DesignGetItemResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"content" : @"content",
       @"title" : @"title",
       @"mask" : @"maskImageURL",
       @"d" : @"_description",
       @"pro" : @"isPro",
       @"status" : @"publishStatus",
       @"uid" : @"uid",
       @"uthumb" : @"uthumb",
       @"uname" : @"author",
       @"rt" : @"roomType",
       @"images" : @"images",
       @"modified" : @"timestamp"
       }];
    
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                                                  toKeyPath:@"shoppingListItems"
                                                                                withMapping:[ShoppingListItem jsonMapping]]];
    
    return entityMapping;
}

- (void)applyPostServerActions
{
    [super applyPostServerActions];
    
    self.productsToVariationsMapping = [NSMutableDictionary new];
   
    if (self.content) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[self.content dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers error:nil];
        NSArray * models = [dict objectForKey:@"models"];
        
        if (models) {
            self.uniqueContentItemsIds = [[NSMutableArray alloc] init];
            for (int i = 0; i<[models count] ; i++) {
                NSDictionary * dictModel = [models objectAtIndex:i];
                
                NSString* productId = [dictModel objectForKey:@"productId"];
                NSString* variantId = [dictModel objectForKey:@"variationId"];
                
                if (!variantId)
                    variantId = productId;
                
                [self.productsToVariationsMapping setObject:variantId forKey:productId];
                
                if (![self.uniqueContentItemsIds containsObject:productId]) {
                    [self.uniqueContentItemsIds addObject:productId];
                }
            }
        }
    }
    
    //items
    for (int i=0; i<[self.shoppingListItems count]; i++) {
        ShoppingListItem * item=[self.shoppingListItems objectAtIndex:i];
        // isNewProduct "t = New" is not correct  in server.
        [[ModelsHandler sharedInstance] addShoppingListItemFromParsedDesign:item];
        if ([item respondsToSelector:@selector(applyPostServerActions)]) {
            [item applyPostServerActions];
        }
    }
    
    //images
    for (int i=0; i<[self.images count]; i++)
    {
        if (i==0) {
            self.originalImageURL=[self.images objectAtIndex:i];
            if (self.url==nil && [self.images count]==1) {
                self.url=self.originalImageURL;
            }
        }
        if (i==1) {
            self.backgroundImageURL=[self.images objectAtIndex:i];
            
        }
        if (i==2) {
            self.editedImageURL=[self.images objectAtIndex:i];
            if (self.url==nil) {
                self.url=[self.images objectAtIndex:i];
            }
        }
    }
}
@end
