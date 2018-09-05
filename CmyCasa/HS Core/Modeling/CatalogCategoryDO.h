//
//  CatalogCategoryDO.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import <Foundation/Foundation.h>
#import "RestkitObjectProtocol.h"
#import "CatalogSideMenuProtocols.h"

#define BRAND_PRODUCT_CATEGORY @"103"

@interface CatalogCategoryDO : NSObject <RestkitObjectProtocol, CatalogSideMenuItemProtocol>

@property(nonatomic,copy)NSString *categoryId;
@property(nonatomic,copy)NSString *categoryName;
@property(nonatomic,copy)NSString *categoryParentId;
@property(nonatomic,strong)NSArray *arrChildren;
@property(nonatomic,copy)NSString *categoryLogo;
@property(nonatomic,strong)NSNumber *categoryStatus;

- (BOOL) isBrandCategory;
- (NSString*) getCategoryIconUrl:(Boolean) isRetina;

@end
