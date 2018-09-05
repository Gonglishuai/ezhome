//
//  CategoryProductsResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import "WishListResponse.h"
#import "WishListProductDO.h"

@implementation WishListResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
 
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wishlists"
                                                 toKeyPath:@"wishList"
                                               withMapping:[WishListProductDO jsonMapping]]];
    return entityMapping;
}

-(void)applyPostServerActions
{
}


@end
