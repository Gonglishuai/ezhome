//
//  ProductInfoDO.h
//  Homestyler
//
//  Created by Dan Baharir on 3/31/15.
//
//

#import <Foundation/Foundation.h>
@class ProductDO;

@interface ProductInfoDO : NSObject

@property (nonatomic,strong) ProductDO *product;
@property (nonatomic,strong) CatalogGroupDO *firstFamily;
@property (nonatomic,strong) NSMutableArray *firstFamilyProducts;
@property (nonatomic,strong) NSMutableArray *familySlibings;


-(instancetype)initWithDictionary:(NSDictionary*)productInfoDict;
@end
