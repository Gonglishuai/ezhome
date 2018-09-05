//
//  CreateWishListResponse.m
//  Homestyler
//
//
//

#import "CreateWishListResponse.h"

@implementation CreateWishListResponse

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
    
    return entityMapping;
}

-(void)applyPostServerActions
{
}


@end
