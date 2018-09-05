//
//  WishlistHandler.m
//  Homestyler
//
//  Created by TomerHar Yoffi.
//
//

#import "WishlistHandler.h"
#import "ProductRO.h"
#import "ProductItemResponse.h"
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
#import "WishListProductDO.h"


@interface WishlistHandler ()
{
    NSMutableArray * _wishListCopy;
    NSMutableArray * _wishListToProductsArrayCopy;
    NSMutableDictionary * _productToWishlistsDict;
    NSMutableDictionary * _wishlistIdToWishlistResponseObjDict;
    BOOL _isReveseMapReady;
}

@end

@implementation WishlistHandler

static WishlistHandler *sharedInstance = nil;

+ (WishlistHandler *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[WishlistHandler alloc] init];
    });
    
    return sharedInstance;
}

-(id)init {
    if ( self = [super init] ) {
        _wishListCopy = [NSMutableArray array];
        _wishlistIdToWishlistResponseObjDict = [NSMutableDictionary dictionary];
        _isReveseMapReady = NO;
    }
    return self;
}

-(BOOL)isReveseMapReady{
    return _isReveseMapReady;
}

-(NSArray*)getWishlist{
    return _wishListCopy;
}

-(NSDictionary*)getProductToWishlistsDict{
    return _productToWishlistsDict;
}

#pragma mark - Wishlist
//- (void)getWishListForUserEmail:(NSString*)email
//            withCompletionBlock:(HSCompletionBlock)completion
//                          queue:(dispatch_queue_t)queue {
//    /*
//     *  Upon completion, update the shopping list with the new products
//     *  for caching purposes and call the requested completion block
//     */
//    ROCompletionBlock completionBlock = ^(id serverResponse) {
//        
//        WishListResponse *wlResponse = (WishListResponse*)serverResponse;
//        if (API_ERROR_CODE == wlResponse.errorCode)
//        {
//            @synchronized(self){
//                
//                _wishListCopy = [wlResponse.wishList mutableCopy];
//                
//                for (WishListProductDO *wlpdo in _wishListCopy) {
//                    CreateWishListResponse * cwlr = [[CreateWishListResponse alloc] init];
//                    cwlr.wishlistId = wlpdo.productId;
//                    cwlr.wishlistName = wlpdo.productName;
//                    cwlr.wishlistDescription = wlpdo.productDescription;
//                    cwlr.wishlistProductCount = wlpdo.productCount;
//                    
//                    [_wishlistIdToWishlistResponseObjDict setObject:cwlr forKey:wlpdo.productId];
//                }
//                
//                if (completion)
//                    completion(_wishListCopy, nil);
//            }
//        }
//        else
//        {
//            if(completion)
//                completion(nil, wlResponse.hsLocalErrorGuid);
//        }
//    };
//    
//    /*
//     *  Upon error, read and raise the error to the caller using the completion block
//     */
//    ROFailureBlock failureBlock = ^(NSError *error) {
//        
//        NSString *erMessage = [error localizedDescription];
//        
//        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
//                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
//        
//        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
//                                                                    withPrevGuid:nil];
//        if(completion)
//            completion(nil,errguid);
//    };
//    
//    [[WishlistRO new] getWishListByEmailString:email
//                               completionBlock:completionBlock
//                                  failureBlock:failureBlock
//                                         queue:queue];
//}

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

-(void)getWishListUserIdForEmail:(NSString*)email
             withCompletionBlock:(HSCompletionBlock)completion
                           queue:(dispatch_queue_t)queue{
    
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        GetWishListUserIdResponse *gwluir = (GetWishListUserIdResponse*)serverResponse;
        if (API_ERROR_CODE == gwluir.errorCode)
        {
            if (completion)
                completion(gwluir.wishlistUserId, nil);
        }
        else
        {
            if(completion)
                completion(nil, gwluir.hsLocalErrorGuid);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };

    [[WishlistRO new] getWishListUserIdForEmail:email
                                completionBlock:completionBlock
                                   failureBlock:failureBlock
                                          queue:queue];
}

-(void)createNewWishListName:(NSString*)wishListName
                 withProduct:(NSString*)productSku
          withWishListUserId:(NSString*)wishListUserId
         withCompletionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue{
    
    
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        CreateWishListResponse *cwlr = (CreateWishListResponse*)serverResponse;
        if (API_ERROR_CODE == cwlr.errorCode)
        {
            @synchronized(self){
                //update wishlist copy array
                WishListProductDO* wlpdo = [[WishListProductDO alloc] init];
                wlpdo.productId = cwlr.wishlistId;
                wlpdo.productName = wishListName;
                wlpdo.productDescription = @"";
                wlpdo.productCount = @"1";
                
                if (_wishListCopy) {
                    [_wishListCopy addObject:wlpdo];
                }
                
                //help dict
                [_wishlistIdToWishlistResponseObjDict setObject:cwlr forKey:wlpdo.productId];
                
                if (completion)
                    completion(cwlr.wishlistId, nil);
            }
        }
        else
        {
            if(completion)
                completion(nil, cwlr.hsLocalErrorGuid);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };

    
    [[WishlistRO new] createNewWishListName:wishListName
                               withProduct:productSku
                        withWishListUserId:wishListUserId
                             completionBlock:completionBlock
                                failureBlock:failureBlock
                                       queue:queue];
}

//not use
//-(void)addProductToWishListId:(NSString*)wishListId
//                 withProduct:(NSString*)productSku
//         withCompletionBlock:(HSCompletionBlock)completion
//                       queue:(dispatch_queue_t)queue{
//    if (wishListId == nil || productSku == nil) {
//        if(completion)
//            completion(nil, @"Params are nil");
//    }
//    
//    ROCompletionBlock completionBlock = ^(id serverResponse)
//    {
//        CreateWishListResponse *cwlr = (CreateWishListResponse*)serverResponse;
//        if (API_ERROR_CODE == cwlr.errorCode)
//        {
//            if (completion)
//                completion(cwlr, nil);
//        }
//        else
//        {
//            if(completion)
//                completion(nil, cwlr.hsLocalErrorGuid);
//        }
//    };
//    
//    ROFailureBlock failureBlock = ^(NSError *error) {
//        
//        NSString *erMessage = [error localizedDescription];
//        
//        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
//                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
//        
//        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
//                                                                    withPrevGuid:nil];
//        if(completion)
//            completion(nil,errguid);
//    };
//    
//    [[WishlistRO new] addProductToWishListId:wishListId
//                              withProduct:productSku
//                          completionBlock:completionBlock
//                             failureBlock:failureBlock
//                                    queue:queue];
//}

-(void)updateProductToWishLists:(NSArray*)wishLists
                 withProductSku:(NSString*)productSku //for api
                  withProductId:(NSString*)productId //for the revese map
                      operation:(OperationType)operationType
            withCompletionBlock:(HSCompletionBlock)completion
                          queue:(dispatch_queue_t)queue{
    
    if (wishLists == nil || productSku == nil) {
        if(completion)
            completion(nil, @"Params are nil");
    }
    
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        CreateWishListResponse *cwlr = (CreateWishListResponse*)serverResponse;
        if (API_ERROR_CODE == cwlr.errorCode)
        {
            @synchronized(self){
                //update wishlist all wishlist -> product
                for (NSString* wishListId in wishLists) {
                    //validity check
                    if (_wishListToProductsArrayCopy) {
                        
                        if (operationType == OPERATION_TYPE_ADD) {
                            //if exist
                            
                            BOOL foundWishList = NO;
                            for (NSInteger i = 0; i < [_wishListToProductsArrayCopy count]; i++) {
                                WishListProductResponse * wlpr = [_wishListToProductsArrayCopy objectAtIndex:i];
                                
                                //search for the existing wishlist
                                if ([wlpr.wishlistId isEqualToString:wishListId]) {
                                    //found the relevant wishlist
                                    
                                    wlpr.wishlistProductCount = [NSString stringWithFormat:@"%d", [wlpr.wishlistProductCount intValue] +1];
                                    
                                    //create new product and add it to the wishlist product array
                                    ProductDO * product =[[ProductDO alloc] init];
                                    product.productId = productId;
                                    
                                    NSMutableArray * temp = [NSMutableArray arrayWithArray:wlpr.wishListProducts];
                                    [temp addObject:product];
                                    wlpr.wishListProducts = [temp mutableCopy];
                                    foundWishList = YES;
                                    break;
                                }
                                
                            }//end for
                            
                            if (!foundWishList) {
                                //wishlist not found
                                CreateWishListResponse *wishlistResponds = [_wishlistIdToWishlistResponseObjDict objectForKey:wishListId];
                                
                                ProductDO * product = [[ProductDO alloc] init];
                                product.productId = productId;
                                
                                //create
                                WishListProductResponse * wlpr = [[WishListProductResponse alloc] init];
                                wlpr.wishlistId = wishlistResponds.wishlistId;
                                wlpr.wishlistName = wishlistResponds.wishlistName;
                                wlpr.wishlistProductCount = @"1";
                                wlpr.wishListProducts = [NSMutableArray arrayWithObject:product];
                                
                                //add whishlist to product item to the copy array
                                [_wishListToProductsArrayCopy addObject:wlpr];
                            }
                        }else if (operationType == OPERATION_TYPE_REMOVE) {
                            
                            for (NSInteger i = 0; i < [_wishListToProductsArrayCopy count]; i++) {
                                WishListProductResponse * wlpr = [_wishListToProductsArrayCopy objectAtIndex:i];
                                
                                //search for the existing wishlist
                                if ([wlpr.wishlistId isEqualToString:wishListId]) {
                                    //found the relevant wishlist
                                    //search for the item in the array
                                    
                                    for (NSInteger j = 0; j < [wlpr.wishListProducts count]; j++) {
                                        ProductDO * product = [wlpr.wishListProducts objectAtIndex:j];
                                        if ([product.productId isEqualToString:productId]) {
                                            //found the item should remove it
                                            NSMutableArray * temp = [NSMutableArray arrayWithArray:wlpr.wishListProducts];
                                            [temp removeObjectAtIndex:j];
                                            wlpr.wishListProducts = [temp mutableCopy];
                                            wlpr.wishlistProductCount = [NSString stringWithFormat:@"%d", [wlpr.wishlistProductCount intValue] -1];
                                            break;
                                        }
                                    }
                                }else{
                                    //wishlist not found
                                }
                            }
                        }
                    }else{
                        //[_wishListAllproductsCopy count] = 0
                        CreateWishListResponse *cwlr = [_wishlistIdToWishlistResponseObjDict objectForKey:wishListId];
                        
                        ProductDO * product = [[ProductDO alloc] init];
                        product.productId = productId;
                        
                        //create
                        WishListProductResponse * wlpr = [[WishListProductResponse alloc] init];
                        wlpr.wishlistId = cwlr.wishlistId;
                        wlpr.wishlistName = cwlr.wishlistName;
                        wlpr.wishlistProductCount = @"1";
                        wlpr.wishListProducts = [NSMutableArray arrayWithObject:product];
                        
                        //add whishlist to product item to the copy array
                        [_wishListToProductsArrayCopy addObject:wlpr];
                    }
                }
                
                [self generateProductToWishListMap:completion response:cwlr];
            }
        }
        else
        {
            if(completion)
                completion(nil, cwlr.hsLocalErrorGuid);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };
    
    [[WishlistRO new] updateProductToWishLists:wishLists
                                withProduct:productSku
                                  operation:(OperationType)operationType
                            completionBlock:completionBlock
                               failureBlock:failureBlock
                                      queue:queue];
    
}

-(void)getCompleteWishListsForEmail:(NSString*)email
                withCompletionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue{
    
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        WishListAllResponse *wlar = (WishListAllResponse*)serverResponse;
        if (API_ERROR_CODE == wlar.errorCode)
        {
            @synchronized(self){
                _wishListToProductsArrayCopy = [NSMutableArray arrayWithArray:[wlar.wishListAllArray copy]];
                
                //hotfix for improving performance
                [_wishListCopy removeAllObjects];
                
                for (CreateWishListResponse * cwlr in _wishListToProductsArrayCopy) {
                    WishListProductDO  * wlpdo = [[WishListProductDO alloc] init];
                    wlpdo.productId = cwlr.wishlistId;
                    wlpdo.productName = cwlr.wishlistName;
                    wlpdo.productDescription = cwlr.wishlistDescription;
                    wlpdo.productCount = cwlr.wishlistProductCount;

                    [_wishListCopy addObject:wlpdo];
                    
                    [_wishlistIdToWishlistResponseObjDict setObject:cwlr forKey:wlpdo.productId];
                }
            
                //create revese map
                [self generateProductToWishListMap:completion response:wlar.wishListAllArray];
            }
        }
        else
        {
            if(completion)
                completion(nil, wlar.hsLocalErrorGuid);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };
    
    [[WishlistRO new] getCompleteWishListsForEmail:email
                           completionBlock:completionBlock
                              failureBlock:failureBlock
                                     queue:queue];
    
}

-(void)deleteWishlist:(NSString*)wishListId
  withCompletionBlock:(HSCompletionBlock)completion
                queue:(dispatch_queue_t)queue
{
    __block NSString* weakWishListId = wishListId;
    ROCompletionBlock completionBlock = ^(id serverResponse)
    {
        BaseResponse *br = (BaseResponse*)serverResponse;
        if (API_ERROR_CODE == br.errorCode)
        {
            @synchronized(self){
                //update wishlist copy array
                if (weakWishListId && _wishListCopy) {
                    for (NSInteger i = 0; i < [_wishListCopy count]; i++) {
                        WishListProductDO* wlpdo = [_wishListCopy objectAtIndex:i];
                        if ([wlpdo.productId isEqualToString:weakWishListId]) {
                            [_wishListCopy removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
                
                //update wishlist all wishlist -> product
                if (_wishListToProductsArrayCopy && [_wishListToProductsArrayCopy count] > 0) {
                    for (NSInteger i = 0; i < [_wishListToProductsArrayCopy count]; i++) {
                        WishListProductResponse * wlpr = [_wishListToProductsArrayCopy objectAtIndex:i];
                        if ([wlpr.wishlistId isEqualToString:weakWishListId]) {
                            [_wishListToProductsArrayCopy removeObjectAtIndex:i];
                            break;
                        }
                    }
                    
                    //create revese map
                    [self generateProductToWishListMap:completion response:br];
                }
            }
        }
        else
        {
            if(completion)
                completion(nil, br.hsLocalErrorGuid);
        }
    };
    
    ROFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *erMessage = [error localizedDescription];
        
        ErrorDO *serverError = [[ErrorDO alloc]initErrorWithDetails:erMessage
                                                      withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL];
        
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:serverError
                                                                    withPrevGuid:nil];
        if(completion)
            completion(nil,errguid);
    };
    
    [[WishlistRO new] deleteWishList:wishListId
                    completionBlock:completionBlock
                       failureBlock:failureBlock
                              queue:queue];
    
}

-(void)generateProductToWishListMap:(HSCompletionBlock)completion response:(id)responseObj{
    if (!_productToWishlistsDict) {
        _productToWishlistsDict = [[NSMutableDictionary alloc] init];
    }else{
        [_productToWishlistsDict removeAllObjects];
    }
    
    //go throw all wishlist array and for each wishlist get the products array
    for (WishListProductResponse * wl in _wishListToProductsArrayCopy) {
        NSArray * products = wl.wishListProducts;
        
        //now for each product
        for (ProductDO * product in products) {
            
            //check is the product allready appar in dictionary
            NSMutableArray * wishlistArray = [_productToWishlistsDict objectForKey:product.productId];
            
            if (!wishlistArray) {
                //case 1 no wishlist at all -> add
                wishlistArray = [[NSMutableArray alloc] init];
                [wishlistArray addObject:wl.wishlistId];
                [_productToWishlistsDict setObject:wishlistArray forKey:product.productId];
            }else{
                //case 2 to wishlist array exist
                //check if array contain the specific wishlist id if yes do nothing else add wishlist id
                if (![wishlistArray containsObject:wl.wishlistId]) {
                    [wishlistArray addObject:wl.wishlistId];
                }
            }
        }
    }//end for
    
    NSLog(@"DONE DOING ProductToWishListMap");
    _isReveseMapReady = YES;

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowWishlistButton" object:nil];

    if (completion)
        completion(responseObj, nil);
}

@end
