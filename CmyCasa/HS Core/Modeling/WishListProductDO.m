//
//  WishListProductDO.m
//  Homestyler
//

//
//

#import "WishListProductDO.h"
#import "ModelsHandler.h"

@interface WishListProductDO()
@end


@implementation WishListProductDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
  
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"productId",
       @"name" : @"productName",
       @"description" : @"productDescription",
       @"productCount" : @"productCount",
       }];
    
    return entityMapping;
}

-(void)applyPostServerActions
{
   
}
@end
