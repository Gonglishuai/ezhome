//
//  CatalogCategoryDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/1/13.
//
//

#import "CatalogCategoryDO.h"

@implementation CatalogCategoryDO


+ (RKObjectMapping*)jsonMapping
{

    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id"        :   @"categoryId",
       @"name"      :   @"categoryName",
       @"parentId"  :   @"categoryParentId",
       @"logo"      :   @"categoryLogo",
       @"status"    :   @"categoryStatus"
       }];
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"categories"
                                                 toKeyPath:@"arrChildren"
                                               withMapping:entityMapping]];

    
    return entityMapping;
}
-(void)applyPostServerActions{
    
    
    
}

- (BOOL) isBrandCategory{
    if (self.categoryId==nil) {
        return NO;
    }
    
    return [self.categoryId isEqualToString:BRAND_PRODUCT_CATEGORY];
}

- (NSString*) getCategoryIconUrl:(Boolean) isRetina {
    
    NSString* url = [[ConfigManager sharedInstance] CATEGORY_ICON_URL];
    
    if (isRetina) {
        url = [[ConfigManager sharedInstance] CATEGORY_RETINA_ICON_URL];
    }
    
    if (self.categoryLogo) {
        return [url stringByReplacingOccurrencesOfString:@"{{ID}}" withString:self.categoryLogo];
    }
   // NSString* iconName = (NSString*) [_topLevelCategoryIcons objectForKey:categoryId];
    return nil;
}

#pragma mark - CatalogSideMenuItemProtocol

- (NSString *)getName
{
    return self.categoryName;
}

- (BOOL)hasChildren
{
    return ((self.arrChildren != nil) && (self.arrChildren.count > 0));
}

- (NSString *)getId
{
    return self.categoryId;
}

- (NSString *)getParentId
{
    return self.categoryParentId;
}

- (NSArray *)getChildren
{
    return self.arrChildren;
}

@end
