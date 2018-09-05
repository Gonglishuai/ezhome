//
//  CategoriesResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/2/13.
//
//

#import "CategoriesResponse.h"
#import "CatalogCategoryDO.h"
@implementation CategoriesResponse

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"items"
                                                 toKeyPath:@"topLevelCategories"
                                               withMapping:[CatalogCategoryDO jsonMapping]]];
    return entityMapping;
}


- (void)applyPostServerActions
{
    if (self.topLevelCategories == nil)
    {
        self.topLevelCategories = [NSMutableArray array];
        self.allCategories = [NSDictionary dictionary];
       
        
        return;
    }
    
    // this is a woodoo patch to remove the following categories from the response (build and style)
    NSMutableArray *finalArr = [NSMutableArray array];
    
    
    //Add category new to the list
    if ([ConfigManager isNewCategoryActive]) {
        CatalogCategoryDO * newCat = [[CatalogCategoryDO alloc] init];
        [newCat setCategoryId:@"new"];
        [newCat setCategoryName:@"New"];
        [newCat setCategoryParentId:@"0"];
        [newCat setCategoryLogo:@"new"];
        [newCat setCategoryStatus:[NSNumber numberWithInt:1]];
        [finalArr addObject:newCat];
    }
  

    for (CatalogCategoryDO *cat in self.topLevelCategories)
    {
        NSString * categoryName = cat.categoryName;
        NSString * lowerCase = [categoryName lowercaseString];
        if ([lowerCase isEqualToString:@"style"] ||
            [lowerCase isEqualToString:@"colors"]) {
            continue;
        }
        
        [finalArr addObject:cat];
    }
    
    self.topLevelCategories = finalArr;

    NSMutableDictionary *dicAllCats = [NSMutableDictionary dictionary];
    
    [self populateCategoriesDictionary:dicAllCats withCategories:finalArr];
    
    self.allCategories = dicAllCats;
}

//this is a recursive func but it does a little work and the cat array isn't very large (maayan)
- (void)populateCategoriesDictionary:(NSMutableDictionary *)dic withCategories:(NSArray *)arr
{
    for (CatalogCategoryDO *cat in arr)
    {
        if (cat.categoryId != nil)
        {
            [dic setObject:cat forKey:cat.categoryId];
        }
        
        if ((cat.arrChildren != nil) && (cat.arrChildren.count > 0))
        {
            [self populateCategoriesDictionary:dic withCategories:cat.arrChildren];
        }
    }
}

@end
