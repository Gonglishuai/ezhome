//
//  WishListAllResponse.m
//  Homestyler
//
//
//

#import "WishListAllResponse.h"
#import "WishListProductResponse.h"

@implementation WishListAllResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
  
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"wishlists"
                                                 toKeyPath:@"wishListAllArray"
                                               withMapping:[WishListProductResponse jsonMapping]]];
    

    
    return entityMapping;
}



@end
