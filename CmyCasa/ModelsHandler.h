//
//  ModelsHandler.h
//  CmyCasa
//
//  Created by Dor Alon on 2/4/13.
//
//

#import <Foundation/Foundation.h>
#import "ShoppingListItem.h"
#import "ProtocolsDef.h"
#import "ModelsDownloadHandler.h"
#import "ProductDO.h"

@class CatalogCategoryDO;

@interface ModelsHandler : NSObject

@property (nonatomic,strong) UIFont * catalogFont;
@property (nonatomic,strong) NSMutableArray * productInfoArray; //for each model holds his meta data


+ (id)sharedInstance;
- (void)clearMetadata;
- (void)loadLocalStoragateCatalog;
- (BOOL)isCategoryToProductExistsForCategory:(NSString*)categoryId;

- (NSString*)getModelFilePath:(NSString*)modelId;
- (NSString*)getModelThumbnailFilePath:(NSString*)modelId;
- (NSString*)getModelVendorImageFilePath:(NSString*)vendorName;
- (NSString*)getModelFileUrl:(NSString*)modelId andVariationId:(NSString*)variationId;
- (NSString*)getCategoryIconUrl:(NSString*)categoryId :(Boolean) isRetina;
- (NSString*)getModelsPath;
- (NSString*)getNewModelIdIfExists:(NSString*)modelId;
- (BOOL)deleteAllModelsData;

- (NSArray*)getCachedModelsFromArray:(NSArray*)models;


- (BOOL) useEncryption;

- (void)getShoppingListItem:(NSString*)productId
               andVariantId:(NSString*)variantId
            completionBlock:(HSCompletionBlock)completion
                      queue:(dispatch_queue_t)queue;

-(void)addShoppingListItemFromParsedDesign:(ProductDO*)item;

-(void)getModelsForCategory:(NSString*)categoryId
                     withCompletionBlock:(HSCompletionBlock)completion
                                   queue:(dispatch_queue_t)queue;

//pagination
- (void)getModelsForCategory:(NSString*)categoryId
                      offset:(NSNumber*)offset
                       limit:(NSNumber*)limit
         withCompletionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue;

- (void)getModelsForSearchString:(NSString*)searchString
             withCompletionBlock:(HSCompletionBlock)completion
                           queue:(dispatch_queue_t)queue;

- (void)updateCategoriesFromServerWithCompletion:(HSCompletionBlock)completion
                                            queue:(dispatch_queue_t)queue;

- (void)searchCatalogAndUpdateProducts:(NSString*)searchString
                   withCompletionBlock:(HSCompletionBlock)completion
                                 queue:(dispatch_queue_t)queue;

- (void)getTopLevelCategoryIdsWithCompletionBlock:(HSCompletionBlock)completion
                                            queue:(dispatch_queue_t)queue;

- (NSMutableArray*) getCategoryChildCategories:(NSString*)categoryId;

- (BOOL)isProductGenericByProductID:(NSString*)prodID;

- (BOOL)isAssembly:(NSString*)modelId;

- (ShoppingListItem*)shoppingListItemForModelId:(NSString*)modelId;

- (void)getProductInfoForEntity:(Entity*)entity
                      completionBlock:(HSCompletionBlock)completion
                                queue:(dispatch_queue_t)queue;

- (void)getProducts:(Entity*)entity
   completionBlock:(HSCompletionBlock)completion
             queue:(dispatch_queue_t)queue;

- (void)getFamiliesByIds:(NSString*)familyIds
                  offset:(NSNumber*)offset
                   limit:(NSNumber*)limit
     withCompletionBlock:(HSCompletionBlock)completion
                   queue:(dispatch_queue_t)queue;

-(NSArray*)getProductInfoArrayForProductId:(NSString*)productId;

@end
