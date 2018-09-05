//
//  ProductInfoDO.m
//  Homestyler
//
//  Created by Dan Baharir on 3/31/15.
//
//

#import "ProductInfoDO.h"
#import "CatalogGroupDO.h"

@implementation ProductInfoDO


-(instancetype)initWithDictionary:(NSDictionary*)productInfoDict{
    
    self = [super init];
    if (self) {
        //product
        self.product = [[ProductDO alloc] init];
        [self.product generateData:[productInfoDict objectForKey:@"product"]];
        
        
        //firstFamily
        self.firstFamily = [[CatalogGroupDO alloc] initWithDictionary:[productInfoDict objectForKey:@"firstFamily"]];

        //familySlibings
        NSArray * familySlibings = [productInfoDict objectForKey:@"familySlibings"];
        self.familySlibings = [NSMutableArray array];
        for (NSDictionary * productDict in familySlibings) {
            CatalogGroupDO * cgdo = [[CatalogGroupDO alloc] initWithDictionary:productDict];
            [self.familySlibings addObject:cgdo];
        }
        
        //firstFamilyProducts
        NSArray * firstFamilyProducts = [productInfoDict objectForKey:@"firstFamilyProducts"];
        
        self.firstFamilyProducts = [NSMutableArray array];
        
        for (NSDictionary * productDict in firstFamilyProducts) {
            ProductDO * catalogBaseProductDO = [[ProductDO alloc] init];
            [catalogBaseProductDO generateData:productDict];

            [self.firstFamilyProducts addObject:catalogBaseProductDO];
        }
    }
    return self;
}

@end
