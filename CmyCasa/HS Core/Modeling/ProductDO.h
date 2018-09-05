//
//  ProductDO.h
//  Homestyler
//
//  Created by Tomer Har Yoffi on 4/16/15.
//
//

#import <Foundation/Foundation.h>

#import "VariationDO.h"
@class CatalogGroupDO;
@class ProductVendorDO;

@interface ProductDO : NSObject <RestkitObjectProtocol>

@property (nonatomic,strong) NSString *productId;
@property (nonatomic,strong) NSString *productType;
@property (nonatomic,strong) NSString *modelUrl;
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *ImageUrl;
@property (nonatomic,strong) NSString *ImagePath;
@property (nonatomic,strong) NSString * sku;
@property (nonatomic,strong) NSNumber * status;
@property (nonatomic,strong) NSString *vendorLogoUrl;
@property (nonatomic,strong) NSString *vendorLink;
@property (nonatomic,strong) NSString *vendorName;
@property (nonatomic,strong) NSString *productLastUpdateTimestamp;
@property (nonatomic,strong) NSString *productLabel;
@property (nonatomic,strong) NSNumber *zedIndex;
@property (nonatomic,strong) NSArray * productImages;
@property (nonatomic,strong) NSArray* retailers;
@property (nonatomic,strong) NSArray* variationsArray;
@property (nonatomic,strong) NSArray *familiesArray;
@property (nonatomic,strong) CatalogGroupDO *firstFamily;
@property (nonatomic,strong) NSMutableArray *firstFamilyProducts;
@property (nonatomic,assign) BOOL IsGeneric;
@property (nonatomic,strong) NSString *isNewProduct;
@property (nonatomic,strong) ProductVendorDO * productVendor;


+ (RKObjectMapping*)jsonMapping;
- (NSString*)getVendorSiteAtIndex:(int)index;
- (BOOL)isAssembly;
- (VariationDO*)getVariationData:(NSString*)variationId;
- (void)applyPostServerActions;
- (void)generateData:(NSDictionary*)data;
@end
