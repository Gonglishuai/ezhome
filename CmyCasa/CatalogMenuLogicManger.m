//
//  CatalogMenuLogicManger.m
//  Homestyler
//
//  Created by Tomer Har Yoffi
//
//

#import "CatalogMenuLogicManger.h"
#import "CatalogCategoryDO.h"
#import "CategoriesResponse.h"
#import "ProductDO.h"
#import "ProgressPopupBaseViewController.h"
#import "WishListProductDO.h"
#import "WishlistHandler.h"
#import "ModelsHandler.h"
#import "DesignsManager.h"

#import "ARViewController.h"

@interface CatalogMenuLogicManger ()
{
    NSArray * _topLevelCategoryIds;
    NSString * _wishListUserId;
}

@end

@implementation CatalogMenuLogicManger


static CatalogMenuLogicManger *sharedInstance = nil;

+ (CatalogMenuLogicManger *)sharedInstance {
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[CatalogMenuLogicManger alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshCatalogDataRequested:)
                                                     name:@"refreshCatalogDataRequestedNotification"
                                                   object:nil];
    }
    
    return self;
}

- (void)refreshCatalogDataRequested:(NSNotification *)notification
{
    [self requestDataRefresh];
}

#pragma mark - CatalogSideMenuDataSourceProtocol
- (void)requestDataRefresh
{
    if (self.catalogType == PRODUCTS_CATALOG) {
        
        [[ModelsHandler sharedInstance] getTopLevelCategoryIdsWithCompletionBlock:^(id serverResponse, id error){
            if (error == nil) {
                
                CategoriesResponse *res = (CategoriesResponse *) serverResponse;
                
                if (res.topLevelCategories == nil || [res.topLevelCategories count] == 0)
                {
                    if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(noCategoriesWereRetrieved)]))
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate noCategoriesWereRetrieved];
                        });
                    }
                    return;
                }
                
                _topLevelCategoryIds = [res.topLevelCategories copy];
                
                //update side menu with top level and all categories
                [self.sideMenu setDataArray:res.topLevelCategories
                         andItemsDictionary:res.allCategories
                                catalogType:PRODUCTS_CATALOG];

                if ([res.topLevelCategories count] > 0)
                {
                    if ([[DesignsManager sharedInstance] workingDesign].dirty == YES || [self.delegate isMemberOfClass:[ARViewController class]]) {
                        if (self.selectedCategoryId && [CatalogMenuLogicManger sharedInstance].searchHistory == nil) {
                            for (CatalogCategoryDO *object in _topLevelCategoryIds) { //判断列表记录是一级目录还是二级目录
                                if ([object.categoryId isEqualToString:self.selectedCategoryId]) {
                                    [self.delegate categorySelected:self.selectedCategoryId catalogType:PRODUCTS_CATALOG];
                                    return;
                                }
                            }
                            [self.sideMenu reloadSideMenuForCategoryId:self.selectedCategoryId];
                            return;
                        }
                    }
                    
                    //simulate the selection of new category
                    NSString *defaultCategory = [[ConfigManager sharedInstance] catalogDefaultCategory];
                    if (defaultCategory && defaultCategory.length > 0){
                        //side menu
                        //[self.sideMenu reloadSideMenuForCategoryId:defaultCategory];
                        if (!self.selectedCategoryId && [CatalogMenuLogicManger sharedInstance].searchHistory) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.delegate searchCatalog:[CatalogMenuLogicManger sharedInstance].searchHistory];
                            });
                        }else{
                            //catalog table
                            [self.delegate categorySelected:defaultCategory catalogType:PRODUCTS_CATALOG];
                        }
                    }else{
                        if ([res.allCategories count] > 0) {
                            //this is very odd but Mosh wanted it like that:
                            //in the side menu showing root (top level categories)
                            //in the product area showing the first categories of allCategories
                        
                            NSArray *values = [res.allCategories allValues];
                            id val = nil;
                            if ([values count] != 0)
                                val = [values objectAtIndex:0];
                            if ([val isKindOfClass:[CatalogCategoryDO class]]) {
                                [self.delegate categorySelected:[(CatalogCategoryDO*)val categoryId] catalogType:PRODUCTS_CATALOG];
                            }
                            
                            [self.sideMenu reloadSideMenu];
                        }
                    }
                }
            }
            
        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }else if (self.catalogType == WISHLIST_CATALOG) {
        //get wishlist from server
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL sholdShowError = NO;
            if (![[WishlistHandler sharedInstance] getWishlist]){
                sholdShowError = YES;
            }
            
            if ([[[WishlistHandler sharedInstance] getWishlist] count] == 0) {
                sholdShowError = YES;
            }
            
            if (sholdShowError) {
                if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(noCategoriesWereRetrieved)]))
                {
                    [self.delegate noCategoriesWereRetrieved];
                }
                return;
            }
            
            if (self.sideMenu) {
                [self.sideMenu setDataArray:[[WishlistHandler sharedInstance] getWishlist] andItemsDictionary:[NSDictionary dictionary] catalogType:WISHLIST_CATALOG];
            }
          
            //simulate the selection of the first category
            WishListProductDO * wpdo = [[[WishlistHandler sharedInstance] getWishlist] objectAtIndex:0];
            [self.delegate categorySelected:wpdo.productId catalogType:WISHLIST_CATALOG];
        });
    }
}

-(NSString*)getWishListUserId{
    return _wishListUserId;
}

-(void)getWishListIdForEmail:(HSCompletionBlock)completion{
    UserDO * user = [[UserManager sharedInstance] currentUser];
    
    [[WishlistHandler sharedInstance] getWishListUserIdForEmail:user.userEmail
                                            withCompletionBlock:^(id serverResponse, id error) {
                                                if (error == nil) {
                                                    
                                                    NSString * wishListUserId = (NSString*)serverResponse;
                                                    _wishListUserId = [wishListUserId copy];
                                                    completion(_wishListUserId, nil);
                                                }else{
                                                    NSLog(@"Failed to get wish list user id");
                                                    completion(nil, nil);
                                                }
                                            }queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)backToDefault{
  
    NSString *defaultCategory = [[ConfigManager sharedInstance] catalogDefaultCategory];
    if (defaultCategory){
        //side menu
        [self.sideMenu backToTopLevelCategory];
        
        //catalog table
        [self.delegate categorySelected:defaultCategory catalogType:PRODUCTS_CATALOG];
    }
}


@end
