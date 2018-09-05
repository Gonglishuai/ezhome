//
//  CatalogGroupsDO.m
//  Homestyler
//
//  Created by Dan Baharir on 2/15/15.
//
//

#import "CatalogGroupsDO.h"
#import "CatalogGroupDO.h"

@implementation CatalogGroupsDO

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self)
    {
        self.family = [[CatalogGroupDO alloc] initWithDictionary:[dict objectForKey:@"family"]];
        NSMutableArray *products = [NSMutableArray array];

        NSArray *productsFromDict = [dict objectForKey:@"products"];
        for (NSDictionary *product in productsFromDict)
        {
            ProductDO *currentProduct = [[ProductDO alloc] init];
            [currentProduct generateData:product];
            [products addObject:currentProduct];
        }
        
        self.products = products;
    }
   
    return  self;
}


@end
