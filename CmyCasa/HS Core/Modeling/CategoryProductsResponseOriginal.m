//
//  CategoryProductsResponseOriginal.m
//  Homestyler
//
//  Created by Dan Baharir on 3/29/15.
//
//

#import "CategoryProductsResponseOriginal.h"

@implementation CategoryProductsResponseOriginal

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:@{
                                                        @"didUMean" : @"searchSuggestionWord",
                                                        }];
    
    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                                                  toKeyPath:@"products"
                                                                                withMapping:[ProductDO jsonMapping]]];
    
    
    return entityMapping;
}

-(void)applyPostServerActions
{
    for (ProductDO *prod in self.products)
    {
        [prod applyPostServerActions];
    }
}

@end
