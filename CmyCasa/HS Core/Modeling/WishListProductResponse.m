//
//  WishListProductResponse.m
//  Homestyler
//
//
//

#import "WishListProductResponse.h"
#import "ProductDO.h"

@implementation WishListProductResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"wishlistId",
       @"name" : @"wishlistName",
       @"description" : @"wishlistDescription",
       @"productCount" : @"wishlistProductCount"
       }];
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                 toKeyPath:@"wishListProducts"
                                               withMapping:[ProductDO jsonMapping]]];
    return entityMapping;
}

-(void)applyPostServerActions
{
    for (ProductDO *prod in self.wishListProducts)
    {
        [prod applyPostServerActions];
    }
}


@end
