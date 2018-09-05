 //
//  iPadModelsHandler.m
//  CmyCasa
//
//  Created by Dor Alon on 2/4/13.
//
//

#import "ModelsHandler.h"
#import "ProductRO.h"
#import "ProductItemResponse.h"
#import "CatalogRO.h"
#import "WishlistRO.h"
#import "ProductDO.h"
#import "CatalogCategoryDO.h"
#import "CategoriesResponse.h"
#import "GetChangedModelsRO.h"
#import "HSMacros.h"
#import "WishListResponse.h"
#import "WishListProductResponse.h"
#import "CreateWishListResponse.h"
#import "GetWishListUserIdResponse.h"
#import "WishListAllResponse.h"
#import "FamiliesResponse.h"
#import "CategoryProductsResponseOriginal.h"
#import "ProductInfoDO.h"
#import "FamilyRO.h"
#import "CatalogGroupsDO.h"
#import "CatalogGroupDO.h"


@interface ModelsHandler ()
{
    NSMutableDictionary* _categoriesDictionary;
    NSMutableDictionary* _categoryToProducts;   //stores products for category
    NSMutableDictionary* _offsetToProducts;     //stores products for offset
    NSMutableDictionary* _categoryIds;
    NSString* _modelsDirectoryPath;
    NSString* _categoryIconsDirectoryPath;
    NSMutableArray* _topLevelCategoryIds;       //stores top level category objects
    NSMutableDictionary* _shoppingListItems;
    NSMutableArray * _wishList;
}

@property  (nonatomic, strong) CategoriesResponse *cachedCategories;

@end

@implementation ModelsHandler

static ModelsHandler *sharedInstance = nil;

+ (ModelsHandler *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[ModelsHandler alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([paths count] == 0)
        {
            return nil;
        }
        _categoryToProducts = [NSMutableDictionary dictionaryWithCapacity:0];
        _offsetToProducts = [NSMutableDictionary dictionaryWithCapacity:0];
        _shoppingListItems = [[NSMutableDictionary alloc] init];
        _wishList = [NSMutableArray arrayWithCapacity:0];
        NSString *resolvedPath = [paths objectAtIndex:0];
        
        _modelsDirectoryPath = [resolvedPath stringByAppendingPathComponent:@"models"];
        _categoryIconsDirectoryPath = [resolvedPath stringByAppendingPathComponent:@"icons"];
        
        BOOL isDir;
        NSFileManager *fileManager= [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:_modelsDirectoryPath isDirectory:&isDir]) {
            [fileManager createDirectoryAtPath:_modelsDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
        }

        [self loadLocalStoragateCatalog];
    }
    return self;
}

- (BOOL)isAssembly:(NSString*)modelId
{
    @synchronized(_shoppingListItems) {
        ShoppingListItem* shoppingListItem = [_shoppingListItems objectForKey:modelId];
        if (shoppingListItem) {
            return  [shoppingListItem isAssembly];
        }
    }
    
    return NO;
}

- (ShoppingListItem*)shoppingListItemForModelId:(NSString*)modelId
{
    @synchronized(_shoppingListItems) {
        ShoppingListItem* shoppingListItem = [_shoppingListItems objectForKey:modelId];
        if (shoppingListItem) {
            return  shoppingListItem;
        }
    }
    
    return nil;
}

-(NSArray*)getProductInfoArrayForProductId:(NSString*)productId{
    
    NSArray * res = nil;
    for (ProductInfoDO* pido in self.productInfoArray) {
        ProductDO * cbpdo = [pido product];
        if ([[cbpdo productId] isEqualToString:productId]) {
            res = [NSArray arrayWithArray:pido.firstFamilyProducts];
            break;
        }
    }
    return res;
}


- (BOOL)isProductGenericByProductID:(NSString*)prodID
{
    @synchronized(_shoppingListItems) {
        ShoppingListItem* shoppingListItem = [_shoppingListItems objectForKey:prodID];
        if (shoppingListItem) {
            return  shoppingListItem.IsGeneric;
        }
    }
    
    return YES;
}

- (void) getShoppingListItem:(NSString*)productId
                andVariantId:(NSString*)variantId
             completionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue
{
    @synchronized(_shoppingListItems)
    {
        NSString *productKey = productId;
        
        if (variantId && ![variantId isEqual:@""]) {
            /*
             * The product id, in case of a variant should be modified
             *  to be the variant id as it is the primary key of the object internally
             */
            productKey = variantId;
        }
        
        /*
         *  Look for the item in cache, if found return to the caller
         */
        ShoppingListItem* shoppingListItem = [_shoppingListItems objectForKey:variantId];
        if (shoppingListItem && completion)
        {
            completion(shoppingListItem, nil);
            return;
        }
        
        ROCompletionBlock completeBlock = ^(id serverResponse)
        {
            BaseResponse * response = (BaseResponse*)serverResponse;
            
            if (response && response.errorCode == -1) {
                ProductItemResponse* productItemResponse = (ProductItemResponse*)serverResponse;
                productItemResponse.shoppingListItem.productId = productKey;
                [self addShoppingListItemFromParsedDesign:productItemResponse.shoppingListItem];
                
                if(completion)
                    completion(productItemResponse.shoppingListItem, nil);
                
            } else {
                if(completion)
                    completion(nil, response.hsLocalErrorGuid);
            }
        };
        
        ROFailureBlock failureBlock = ^(NSError *error)
        {
            NSString *erMessage = [error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion) {
                completion(nil,errguid);
            };
            
        };
        
        [[ProductRO new] getproductById:productId
                           andVariantId:variantId
                        completionBlock:completeBlock
                           failureBlock:failureBlock
                                  queue:queue];
    }
}

-(void)addShoppingListItemFromParsedDesign:(ProductDO*)item
{    
    if (item && item.productId) {
        //NSLog(@"add %@ id: %@",item.Name, item.productId);
        [_shoppingListItems setObject:item forKey:item.productId];
    }
}

- (NSMutableArray*)getCategoryChildCategories:(NSString*)categoryId
{
    NSMutableArray *arrChildCats = [NSMutableArray array];
    
    if ((self.cachedCategories == nil) || (categoryId == nil))
    {
        return arrChildCats;
    }
    
    NSDictionary *dicAllCats = self.cachedCategories.allCategories;
    CatalogCategoryDO *cat = [dicAllCats objectForKey:categoryId];
    if (cat != nil)
    {
        arrChildCats = [cat.arrChildren copy];
    }
    
    return arrChildCats;
}

- (NSString*)getModelFilePath:(NSString*)modelId
{
    if ([self useEncryption]) {
        return [self getModelDatFilePath:modelId];
    } else {
        return [self getModelZipFilePath:modelId];
    }
}

- (NSString*) getModelDatFilePath:(NSString*)modelId {
    return [NSString stringWithFormat:@"%@/%@.dat", _modelsDirectoryPath, modelId];
}

- (NSString*) getModelZipFilePath:(NSString*)modelId {
    return [NSString stringWithFormat:@"%@/%@.zip", _modelsDirectoryPath, modelId];
}

- (NSString*) getModelThumbnailFilePath:(NSString*)modelId {
    return [NSString stringWithFormat:@"%@/%@.jpg", _modelsDirectoryPath, modelId];
}

- (BOOL) useEncryption {
    NSString* url = [ModelsHandler getModelZipUrl];
    return [url hasSuffix:@".dat"];
}

+ (NSString*)getModelZipUrl
{
    if (![[UserManager sharedInstance] checkIfModeller])
        return [[ConfigManager sharedInstance] MODEL_ZIP_URL];
    else
        return [[ConfigManager sharedInstance] MODEL_ZIP_URL_NO_CACHE];
}

- (NSString*)getModelFileUrl:(NSString*)modelId andVariationId:(NSString*)variationId
{
    if (!variationId || [variationId isEqualToString:@""] || [modelId isEqualToString:variationId])
    {
        NSString* url = [ModelsHandler getModelZipUrl];
        return [url stringByReplacingOccurrencesOfString:@"{{ID}}" withString:modelId];
    }
    else
    {
        NSString* url = [[ConfigManager sharedInstance] MODEL_ZIP_URL_WITH_VARIATION_ID];
        url = [url stringByReplacingOccurrencesOfString:@"{{ID}}" withString:modelId];
        return [url stringByReplacingOccurrencesOfString:@"{{VAR_ID}}" withString:variationId];
    }
}

- (NSString*) getModelsPath {
    return _modelsDirectoryPath;
}

- (NSString*) getNewModelIdIfExists:(NSString*)modelId {
   
    NSArray* arr = [modelId componentsSeparatedByString:@"_"];
    return [arr objectAtIndex:0];
}

- (NSString*) getModelVendorImageFilePath:(NSString*)vendorName {
    NSCharacterSet *invalidFsChars = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<> "];
    NSString *safeVendorName = [vendorName stringByTrimmingCharactersInSet:invalidFsChars];
    safeVendorName = [safeVendorName stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSString stringWithFormat:@"%@/%@.jpg", _modelsDirectoryPath, safeVendorName];
}

- (BOOL) deleteAllModelsData {
    if( [[NSFileManager defaultManager] removeItemAtPath:_modelsDirectoryPath error:nil]) {
        return [[NSFileManager defaultManager] createDirectoryAtPath:_modelsDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return NO;
}

-(void)clearMetadata
{
    _topLevelCategoryIds = nil;
    [_offsetToProducts removeAllObjects];
    _categoryIds = [NSMutableDictionary dictionaryWithCapacity:0];;
    self.cachedCategories = nil;
}

#pragma mark- Refactored Methods
- (BOOL)isCategoryToProductExistsForCategory:(NSString*)categoryId
{
    return [_categoryToProducts objectForKey:categoryId]!=nil;
}

- (void)getModelsForCategory:(NSString*)categoryId withCompletionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue {
    @synchronized(self) {
        if (![_categoryToProducts objectForKey:categoryId])
        {
            [self updateCategoryProductsFromServer:categoryId withCompletionBlock:completion queue:queue];
        }
        else
        {
            if (completion)
            {
                completion([_categoryToProducts objectForKey:categoryId],nil);
            }
        }
    }
}

- (void) getModelsForCategory:(NSString*)categoryId
                       offset:(NSNumber*)offset
                        limit:(NSNumber*)limit
          withCompletionBlock:(HSCompletionBlock)completion
                        queue:(dispatch_queue_t)queue{
    @synchronized(self) {
        NSString * categoryIdOffset = [NSString stringWithFormat:@"%@_%@", categoryId, offset];
        if (![_offsetToProducts objectForKey:categoryIdOffset])
        {
            [self updateCategoryProductsFromServer:categoryId
                                            offset:offset
                                             limit:limit
                               withCompletionBlock:completion queue:queue];
        }
        else
        {
            if (completion)
            {
                completion([_offsetToProducts objectForKey:categoryIdOffset],nil);
            }
        }
    }
}


- (void)getFamiliesByIds:(NSString*)familyIds
                  offset:(NSNumber*)offset
                   limit:(NSNumber*)limit
     withCompletionBlock:(HSCompletionBlock)completion
                   queue:(dispatch_queue_t)queue
{
    @synchronized(self)
    {
        if (familyIds){
                [[FamilyRO new] getFamiliesByFamiliesIds:familyIds completionBlock:^(id serverResponse) {
            
                NSMutableArray * groupsArray = [NSMutableArray array];
                NSArray * groupsDict = [serverResponse objectForKey:@"items"];

                if (groupsDict) {
                    for (NSDictionary* goupDict in groupsDict) {
                        CatalogGroupsDO * catalogGroupsDO = [[CatalogGroupsDO alloc] initWithDictionary:goupDict];
                        [groupsArray addObject:catalogGroupsDO];
                        [self storeProducts:catalogGroupsDO.products];
                    }
                }
            
                if (groupsArray.count > 0)
                {
                    if (completion) {
                        completion(groupsArray,nil);
                    }
                }else{
                    if(completion){
                        completion(nil,@"error");
                    }
                }
            } failureBlock:^(NSError *error) {
                NSString * erMessage = [error localizedDescription];
                NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage
                                                                                                            withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL]
                                                                        withPrevGuid:nil];
            
                if(completion)completion(nil,errguid);
            } queue:queue];
        }
        else
        {
            if (completion)
            {
                completion(nil,nil);
            }
        }
    }
}

- (void)updateCategoryProductsFromServer:(NSString*)categoryId
                                  offset:(NSNumber*)offset
                                   limit:(NSNumber*)limit
                     withCompletionBlock:(HSCompletionBlock)completion
                                   queue:(dispatch_queue_t)queue {
    
    [[CatalogRO new] getProductsByCategory:categoryId
                                    offset:offset
                                     limit:limit
                           completionBlock:^(id serverResponse) {
        CategoryProductsResponseOriginal * cats = (CategoryProductsResponseOriginal *)serverResponse;
        if (cats.errorCode == -1) {
            NSString * categoryIdOffset = [NSString stringWithFormat:@"%@_%@", categoryId, offset];

            [_offsetToProducts setObject:cats.products forKey:categoryIdOffset];
            [self storeProducts:cats.products];
            
            if (completion) {
                completion(cats.products,nil);
            }
        }else{
            if(completion){
                completion(nil,cats.hsLocalErrorGuid);
            }
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage
                                                                                                        withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL]
                                                                    withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:queue];
}

- (void)getModelsForSearchString:(NSString*)searchString withCompletionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    @synchronized(self)
    {
        if (!completion)
            return;
        
        [self searchCatalogAndUpdateProducts:searchString
                         withCompletionBlock:completion
                                       queue:queue];
    }
}


- (void)updateCategoriesFromServerWithCompletion:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
    
    if (![ConfigManager isAnyNetworkAvailableOrOffline]) {
        [ConfigManager showMessageIfDisconnected];
        
        if (completion) {
            completion(nil,@"");
        }
        return ;
    }
    
    [[CatalogRO new] getRootCategoriesWithcompletionBlock:^(id serverResponse) {
        
        
        CategoriesResponse * cats=(CategoriesResponse*)serverResponse;
        
        if (cats.errorCode == -1) {
            
            self.cachedCategories = serverResponse;
            
            if (completion) {
                completion(cats ,nil);
            }
            
        }else{
            if (completion) {
                completion(nil,cats.hsLocalErrorGuid);
            }
        }
        
    } failureBlock:^(NSError *error) {
        
    } queue:queue];
}

- (void)updateCategoryProductsFromServer:(NSString*)categoryId withCompletionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [[CatalogRO new] getProductsByCategory:categoryId completionBlock:^(id serverResponse) {
        
        CategoryProductsResponseOriginal * cats=(CategoryProductsResponseOriginal*)serverResponse;
        if (cats.errorCode==-1) {
        
            [_categoryToProducts setObject:cats.products forKey:categoryId];
            [self storeProducts:cats.products];
            
            if (completion) {
                completion(cats.products,nil);
            }
        }else{
            
            if(completion) completion(nil,cats.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString * erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion)completion(nil,errguid);
    } queue:queue];
}



- (void)searchCatalogAndUpdateProducts:(NSString*)searchString
                   withCompletionBlock:(HSCompletionBlock)completion
                                 queue:(dispatch_queue_t)queue
{
    /*
     *  Upon completion, update the shopping list with the new products
     *  for caching purposes and call the requested completion block
     */
    ROCompletionBlock completionBlock = ^(id serverResponse) {
        
        NSDictionary *respondDict = serverResponse;
        
        NSArray * items = [respondDict objectForKey:@"items"];
        
        if (items) {
            NSMutableArray * searchResult = [NSMutableArray array];
            
            for (NSDictionary * productDict in items) {
                ProductDO * pdo = [[ProductDO alloc] init];
                [pdo generateData:productDict];
                [searchResult addObject:pdo];
            }
            
            [self storeProducts:searchResult];
            
            if (completion)
                completion(searchResult,nil);
        }
    };
    
    /*
     *  Upon error, read and raise the error to the caller using the completion block
     */
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage=[error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];

        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_SEARCH_STRING
//                withParameters:@{EVENT_PARAM_SEARCH_KEYWORD: searchString}];
    
    [[CatalogRO new] getProductsBySearchString:searchString
                               completionBlock:completionBlock
                                  failureBlock:failureBlock
                                         queue:queue];
    
    
}


- (void) storeProducts:(NSArray*)products {
    @synchronized(_shoppingListItems) {
        for(ProductDO* product in products) {
            //NSLog(@"add %@ id: %@",product.Name, product.productId);
            [_shoppingListItems setObject:product forKey:product.productId];
        }
    }
}

- (void) getTopLevelCategoryIdsWithCompletionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue  {
    @synchronized(self) {
        if (self.cachedCategories == nil)
        {
            [self updateCategoriesFromServerWithCompletion:completion queue:queue];
        }else{
            if (completion) {
                completion(self.cachedCategories, nil);
            }
        }
    }
}

#pragma mark - Catalog Font handling
- (void)loadLocalStoragateCatalog
{
    //1. Check if already downloaded the font
    if (sharedInstance.catalogFont) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSData * data;
                       
                       if (![[ConfigManager sharedInstance] catalogFontURL]) {
                           sharedInstance.catalogFont = [UIFont fontWithName:@"catalog" size:20.0f];
                       }else{
                           NSString * catlogUrl = [[ConfigManager sharedInstance]catalogFontURL];
                           NSURL * url = [NSURL URLWithString:catlogUrl];
                           
                           data = [NSData dataWithContentsOfURL:url];
                           
                           if (data) {
                               
                               CGDataProviderRef fontDataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
                               
                               if (fontDataProvider) {
                                   CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
                                   NSString * fontName = (__bridge NSString *)CGFontCopyPostScriptName(fontRef);
                                   CGDataProviderRelease(fontDataProvider);
                                   if (fontName) {
                                       sharedInstance.catalogFont = [UIFont fontWithName:fontName size:20.0f];
                                   }else{
                                       sharedInstance.catalogFont = [UIFont fontWithName:@"catalog" size:20.0f];
                                   }
                               }
                               
                           }else{
                               sharedInstance.catalogFont = [UIFont fontWithName:@"catalog" size:20.0f];
                           }
                       }
                   });
    
}

-(NSString *)getCategoryIconUrl:(NSString *)categoryId :(Boolean)isRetina{
    return nil;
}

- (void)getProductsForWishListId:(NSString*)wishListId
             withCompletionBlock:(HSCompletionBlock)completion
                           queue:(dispatch_queue_t)queue{
    /*
     *  Upon completion, update the shopping list with the new products
     *  for caching purposes and call the requested completion block
     */
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
            WishListProductResponse *cats = (WishListProductResponse*)serverResponse;
            if (API_ERROR_CODE == cats.errorCode)
            {
                [self storeProducts:cats.wishListProducts];
    
                if (completion)
                    completion(cats.wishListProducts, nil);
            }
            else
            {
                if(completion)
                    completion(nil, cats.hsLocalErrorGuid);
            }
    };
    
    /*
     *  Upon error, read and raise the error to the caller using the completion block
     */
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };
    
    [[WishlistRO new] getProductForWishListId:wishListId
                             completionBlock:completionBlock
                                failureBlock:failureBlock
                                       queue:queue];

    
}

- (NSArray*)getCachedModelsFromArray:(NSArray*)models
{
    NSMutableArray *cachedModels = [NSMutableArray new];
    
    for(id entity in models)
    {
        if (![entity isKindOfClass:[Entity class]])
            continue;
    
        Entity *savedEntity = (Entity*)entity;
        
        NSAssert(savedEntity.variationId, @"Entity must have a valid variation id");
        
        savedEntity.variationId = [self getNewModelIdIfExists:savedEntity.variationId];
        NSString *zipPath = [self getModelFilePath: savedEntity.variationId];
        if ([[NSFileManager defaultManager] fileExistsAtPath: zipPath]) {
            [cachedModels addObject:savedEntity];
        }
    }
    
    return [[NSSet setWithArray:cachedModels] allObjects]; // Return only unique objects
}

- (void)getProductInfoForEntity:(Entity*)entity
                completionBlock:(HSCompletionBlock)completion
                          queue:(dispatch_queue_t)queue
{
    @synchronized(_shoppingListItems)
    {
        ROCompletionBlock completeBlock = ^(id serverResponse)
        {
            NSDictionary* responseDict = (NSDictionary*)serverResponse;
            
            if (responseDict && [[responseDict objectForKey:@"er"] integerValue] == -1)
            {
                NSArray * items = [responseDict objectForKey:@"items"];
                
                self.productInfoArray = [NSMutableArray array];
                
                ProductInfoDO * piDO = nil;
                if ([items count] > 0) {
                    NSDictionary* productDict = [items objectAtIndex:0];
                    piDO = [[ProductInfoDO alloc] initWithDictionary:productDict];
                    
                    //add meta data to array
                    [_productInfoArray addObject:piDO];
                    [self addShoppingListItemFromParsedDesign:piDO.product];
                }
               
                if(completion)
                    completion(piDO, nil);
                
            } else {
                if(completion)
                    completion(nil, [responseDict objectForKey:@"_hsLocalErrorGuid"]);
            }
        };
        
        ROFailureBlock failureBlock = ^(NSError *error)
        {
            NSString *erMessage = [error localizedDescription];
            NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
            
            if(completion) {
                completion(nil,errguid);
            };
        };
        
        NSMutableArray *productIdsList = [NSMutableArray new];
        
        // Add the assembly main modelId to retrieve the global info
        [productIdsList addObject:entity.modelId];
        
        /*
         *  Look for the item in cache, if found return to the caller
         */
        
        [[ProductRO new] getProductInfoForId:productIdsList
                             completionBlock:completeBlock
                                failureBlock:failureBlock
                                       queue:queue];
    }
}


-(void)getProducts:(Entity*)entity
   completionBlock:(HSCompletionBlock)completion
             queue:(dispatch_queue_t)queue{
    
    ROCompletionBlock completeBlock = ^(id serverResponse)
    {
        NSDictionary* responseDict = (NSDictionary*)serverResponse;
        
        if (responseDict && [[responseDict objectForKey:@"er"] integerValue] == -1)
        {
            NSArray * items = [responseDict objectForKey:@"items"];
            
            NSMutableArray * productsArray = [NSMutableArray array];
            
            for (NSDictionary* productDict in items) {
                ProductDO * cbpdo = [[ProductDO alloc] init];
                [cbpdo generateData:productDict];
                [productsArray addObject:cbpdo];
            }
            
            [self storeProducts:productsArray];
            
            if(completion)
                completion(productsArray, nil);
            
        } else {
            if(completion)
                completion(nil, [responseDict objectForKey:@"_hsLocalErrorGuid"]);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error)
    {
        NSString *erMessage = [error localizedDescription];
        NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
        
        if(completion) {
            completion(nil,errguid);
        };
    };
    
    //get the products for the assemblies
    NSMutableArray * productIdsList = [NSMutableArray array];
    NSArray * copyArray = [NSArray arrayWithArray:[entity nestedEntities]];

    for (Entity *nestedEntity in copyArray)
    {
        [productIdsList addObject:nestedEntity.modelId];
    }
    
    [[ProductRO new] getProductsByIds:productIdsList
                      completionBlock:completeBlock
                         failureBlock:failureBlock
                                queue:queue];
    
    
}

@end
