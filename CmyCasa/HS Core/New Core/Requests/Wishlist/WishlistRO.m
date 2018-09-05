//
//  WishlistRO.m
//  Homestyler
//
//
//

#import "WishlistRO.h"
#import "WishListResponse.h"
#import "WishListProductResponse.h"
#import "CreateWishListResponse.h"
#import "GetWishListUserIdResponse.h"
#import "WishListAllResponse.h"
#import "ConfigManager.h"

@implementation WishlistRO

+(void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getWishListForEmail]
                                    withMapping:[WishListResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getProductForWishListId]
                                    withMapping:[WishListProductResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getCreateWishList]
                                    withMapping:[CreateWishListResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getWishListUserId]
                                    withMapping:[GetWishListUserIdResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getAddProductToWishList]
                                    withMapping:[CreateWishListResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getCompleteWishlistsProductMap]
                                    withMapping:[WishListAllResponse jsonMapping]];
}

#pragma mark - wishlist
-(void)getWishListByEmailString:(NSString*)email
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue
{
    
    self.requestQueue = queue;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (email) {
        [params setObject:email forKey:@"email"];
    }
    
    //hot fix whitelabel
    [params setObject:@"en_US" forKey:@"l"];
    
    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];
    
    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];

    [self getObjectsForAction:[[ConfigManager sharedInstance] getWishListForEmail]
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}

-(void)getProductForWishListId:(NSString*)wishListId
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] getProductForWishListId];
    
    if (action)
    {
        action.action = @"wishlist/{{ID}}";
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{ID}}" withString:wishListId];
        
        [BaseRO addResponseDescriptorForPathPattern:action
                                        withMapping:[WishListProductResponse jsonMapping]];
        
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        //hot fix whitelabel
        [params setObject:@"en_US" forKey:@"l"];
        
        [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];
        
        [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];

        [self getObjectsForAction:action
                           params:params
                      withHeaders:YES
                  completionBlock:completion
                     failureBlock:failure];
    }
}


-(void)getWishListUserIdForEmail:(NSString*)email
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] getWishListUserId];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (email) {
        [params setObject:email forKey:@"email"];
    }

    [params setObject:@"en_US" forKey:@"l"];
    
    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];
    
    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];
    
    [self getObjectsForAction:action
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
    
}

-(void)createNewWishListName:(NSString*)wishListName
                 withProduct:(NSString*)productSku
          withWishListUserId:(NSString*)wishListUserId
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;

    ApiAction *action = [[ConfigManager sharedInstance] getCreateWishList];
    
    action.action = @"wishlist/?tenant={{TENANT}}&lang={{LANG}}&userId={{USERID}}&products={{PRODUCTS}}&name={{NAME}}";
    
    if (action)
    {
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{TENANT}}"
                                                                 withString:[ConfigManager getTenantIdName]];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{LANG}}"
                                                                 withString:@"en_US"];
        
        if (!wishListUserId) {
            NSError* error = [NSError errorWithDomain:@"" code:-1 userInfo:nil];
            failure(error);
            return;
        }
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{USERID}}"
                                                                 withString:wishListUserId];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{PRODUCTS}}"
                                                                 withString:productSku];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{NAME}}"
                                                                 withString:wishListName];
        
        [BaseRO addResponseDescriptorForPathPattern:action
                                        withMapping:[CreateWishListResponse jsonMapping]];
        [self postWithAction:action
                      params:params
                 withHeaders:NO
                   withToken:NO
             completionBlock:completion
                failureBlock:failure];
    }
}

-(void)addProductToWishListId:(NSString*)wishListId
                 withProduct:(NSString*)productSku
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] getAddProductToWishList];
    
    action.action = @"wishlist/{{WID}}";
    
    action.action = [action.action stringByReplacingOccurrencesOfString:@"{{WID}}"
                                                             withString:wishListId];
    
    [BaseRO addResponseDescriptorForPathPattern:action
                                    withMapping:[CreateWishListResponse jsonMapping]];
    
    if (action)
    {
        action.action = @"wishlist/{{WID}}?tenant={{TENANT}}&lang={{LANG}}&products={{PRODUCTS}}";
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{TENANT}}"
                                                                 withString:[ConfigManager getTenantIdName]];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{LANG}}"
                                                                 withString:@"en_US"];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{PRODUCTS}}"
                                                                 withString:productSku];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{WID}}"
                                                                 withString:wishListId];
        
        [BaseRO addResponseDescriptorForPathPattern:action
                                        withMapping:[CreateWishListResponse jsonMapping]];
        
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [self putWithAction:action
                     params:params
                withHeaders:NO
                  withToken:NO
            completionBlock:completion
               failureBlock:failure];
    }
}

-(void)getCompleteWishListsForEmail:(NSString*)email
                    completionBlock:(ROCompletionBlock)completion
                       failureBlock:(ROFailureBlock)failure
                              queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] getCompleteWishlistsProductMap];
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (email) {
        [params setObject:email forKey:@"email"];
    }
    
    [params setObject:@"en_US" forKey:@"l"];
    
    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];
    
    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];

    [self getObjectsForAction:action
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
    
}

-(void)deleteWishList:(NSString*)wishListId
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
                queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] deleteWishlist];
    
    action.action = @"wishlist/{{WID}}";
    
    action.action = [action.action stringByReplacingOccurrencesOfString:@"{{WID}}"
                                                             withString:wishListId];
    
    [BaseRO addResponseDescriptorForPathPattern:action
                                    withMapping:[BaseResponse jsonMapping]];
    
    [self deleteWithAction:action
                    params:nil
               withHeaders:NO
                 withToken:NO
           completionBlock:completion
              failureBlock:failure];
}

-(void)updateProductToWishLists:(NSArray*)wishLists
                    withProduct:(NSString*)productSku
                      operation:(OperationType)operationType
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue{
    
    self.requestQueue = queue;
    
    ApiAction *action = [[ConfigManager sharedInstance] updateProductWishLists];
    
    action.action = @"wishlists";
    
    [BaseRO addResponseDescriptorForPathPattern:action
                                    withMapping:[CreateWishListResponse jsonMapping]];
    
    if (action)
    {
        NSMutableString *fullString =  [[NSMutableString alloc] init];
        for (NSObject * obj in wishLists) {
            [fullString appendString:[NSString stringWithFormat:@"%@,", [obj description]]];
        }
        
        if (operationType == OPERATION_TYPE_ADD) {
            action.action = @"wishlists?tenant={{TENANT}}&lang={{LANG}}&products={{PRODUCTS}}&wids={{WIDS}}";
            
            action.action = [action.action stringByReplacingOccurrencesOfString:@"{{WIDS}}"
                                                                     withString:fullString];
            
            action.action = [action.action stringByReplacingOccurrencesOfString:@"{{PRODUCTS}}"
                                                                     withString:productSku];
        }
        
        if (operationType == OPERATION_TYPE_REMOVE) {
            action.action = @"wishlists?tenant={{TENANT}}&lang={{LANG}}&productsToRemove={{PRODUCTSTOREMOVE}}&wids={{WIDS}}";
            
            action.action = [action.action stringByReplacingOccurrencesOfString:@"{{WIDS}}"
                                                                     withString:fullString];
            
            action.action = [action.action stringByReplacingOccurrencesOfString:@"{{PRODUCTSTOREMOVE}}"
                                                                     withString:productSku];
        }
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{TENANT}}"
                                                                 withString:[ConfigManager getTenantIdName]];
        
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{LANG}}"
                                                                 withString:@"en_US"];
        
        
        
        
        [BaseRO addResponseDescriptorForPathPattern:action
                                        withMapping:[CreateWishListResponse jsonMapping]];
        
        NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [self putWithAction:action
                     params:params
                withHeaders:NO
                  withToken:NO
            completionBlock:completion
               failureBlock:failure];
    }
}

@end
