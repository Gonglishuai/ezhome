//
//  ProductDO.m
//  Homestyler
//
//  Created by Tomer Har Yoffi on 4/16/15.
//
//

#import "ProductDO.h"
#import "RetailerDO.h"
#import "ModelsHandler.h"
#import "ProductVendorDO.h"
#import "VariationDO.h"
#import "CatalogGroupDO.h"

@implementation ProductDO

- (void)generateData:(NSDictionary*)dict{
    
    self.productId = [dict objectForKey:@"id"];
    self.productType = [dict objectForKey:@"productType"];
    self.modelUrl = [[dict objectForKey:@"model"] objectForKey:@"modelUrl"];
    self.Name = [dict objectForKey:@"name"];
    
    NSArray * images = [dict objectForKey:@"images"];
    if (images && [images count] > 0) {
        self.ImageUrl  = [images objectAtIndex:0];
        self.productImages = images;
    }

    self.vendorLogoUrl = [dict objectForKey:@"vendorUrl"];
    self.vendorLink = [dict objectForKey:@"vendorLink"];
    self.vendorName = [dict objectForKey:@"vendor"];
    self.zedIndex = [dict objectForKey: @"zIndex"];
    
    //handel retailers
    NSArray * retailersArray = [dict objectForKey:@"retailers"];
    NSMutableArray * retailers = [NSMutableArray array];
    for (NSDictionary * retailsDict in retailersArray) {
        RetailerDO * retailerDO = [[RetailerDO alloc] initWithDictionary:retailsDict];
        [retailers addObject:retailerDO];
    }
    self.retailers  = retailers;
    
    //handel variations
    NSDictionary * variationDict = [dict objectForKey:@"variations"];
    NSArray * colorVariation = [variationDict objectForKey:@"color"];
    NSMutableArray * variations = [NSMutableArray array];
    for (NSDictionary * variationDict in colorVariation) {
        VariationDO * variationDO = [[VariationDO alloc] initWithDictionary:variationDict];
        [variations addObject:variationDO];
    }
    self.variationsArray  = variations;
    
    //handel famelis
    NSMutableArray * famelies = [NSMutableArray array];
    for (NSDictionary * familyDict in [dict objectForKey:@"families"]) {
        CatalogGroupDO * catalogGroupDO = [[CatalogGroupDO alloc] initWithDictionary:familyDict];
        [famelies addObject:catalogGroupDO];
    }
    self.familiesArray  = famelies;
    
    self.firstFamily = [[CatalogGroupDO alloc] initWithDictionary:[dict objectForKey:@"firstFamily"]];
    self.sku = [[dict objectForKey:@"ticket"] objectForKey:@"sku"];
    self.status = [dict objectForKey:@"status"];
    [self applyPostServerActions];
}

-(void)applyPostServerActions
{
    ModelsHandler *modelsHandler = [ModelsHandler sharedInstance];
    
    self.ImagePath = [modelsHandler getModelThumbnailFilePath:self.productId];
    if([self.productImages count] > 0  && [self.productImages objectAtIndex:0 ]!=[NSNull null])
    {
        self.ImageUrl = [self.productImages objectAtIndex:0];
    }
    
    NSString * vendorTempPath = [modelsHandler getModelVendorImageFilePath:self.vendorName];
    
    if (self.retailers && [self.retailers count] > 0)
    {
        RetailerDO* firstRetailer = [self.retailers objectAtIndex:0];
        if ([firstRetailer.name isEqualToString:@"Generic"])
        {
            self.productVendor=[[ProductVendorDO alloc] initWithName:self.vendorName
                                                             andLogo:self.vendorLogoUrl
                                                                path:vendorTempPath
                                                       andProductURL:nil];
            self.IsGeneric = YES;
        }
        else
        {
            self.productVendor=[[ProductVendorDO alloc] initWithName:firstRetailer.name
                                                             andLogo:self.vendorLogoUrl
                                                                path:vendorTempPath
                                                       andProductURL:firstRetailer.url];
            self.IsGeneric = NO;
        }
    }
    
    for (VariationDO *variation in self.variationsArray)
    {
        variation.modelId = self.productId;
    }
    
    if ([self.zedIndex integerValue] == 100)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_DIRECTLY_ON_FLOOR];
    
    if ([self.zedIndex integerValue] == 200)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_LEVITATE_THRESHOLD];
    
    if ([self.zedIndex integerValue] == 300)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_LEVITATE];
    
    if ([self.zedIndex integerValue] == 400)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_ATTACHED_TO_WALL];
    
    if ([self.zedIndex integerValue] == 410)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_ATTACHED_TO_WALL_BOTTOM];
    
    if ([self.zedIndex integerValue] == 500)
        self.zedIndex = [NSNumber numberWithInt:Z_INDEX_ATTACHED_TO_CEILING];
}

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"productId",
       @"name" : @"Name",
       @"vendor" : @"vendorName",
       @"vendorUrl" : @"vendorLogoUrl",
       @"vendorLink" : @"vendorLink",
       @"images" : @"productImages",
       @"productType" : @"productType",
       @"model.modelUrl" : @"modelUrl",
       @"ticket.sku" : @"sku",
       @"status": @"status",
       @"zIndex" : @"zedIndex",
       @"label" : @"productLabel"
       }];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"retailers"
                                                 toKeyPath:@"retailers"
                                               withMapping:[RetailerDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"variations.color"
                                                 toKeyPath:@"variationsArray"
                                               withMapping:[VariationDO jsonMapping]]];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"families"
                                                 toKeyPath:@"familiesArray"
                                               withMapping:[CatalogGroupDO jsonMapping]]];
    
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"firstFamily"
                                                 toKeyPath:@"firstFamily"
                                               withMapping:[CatalogGroupDO jsonMapping]]];
    
    
    return entityMapping;
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString*)getVendorSiteAtIndex:(int)index
{
    if (!self.retailers || !(index < [self.retailers count]))
        return nil;
    
    RetailerDO *rt = [self.retailers objectAtIndex:index];
    return rt.url;
}



////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isAssembly
{
    if (!self.productType)
        return NO;
    
    return [self.productType isEqualToString:@"Assembly"];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (VariationDO*)getVariationData:(NSString*)variationId
{
    RETURN_ON_NIL(variationId, nil);
    RETURN_ON_NIL(self.variationsArray, nil);
    
    if ([self.variationsArray count] == 0)
        return nil;
    
    for (VariationDO *variation in self.variationsArray)
    {
        if ([variation.variationId isEqualToString:variationId])
            return variation;
    }
    
    return nil;
}



@end
