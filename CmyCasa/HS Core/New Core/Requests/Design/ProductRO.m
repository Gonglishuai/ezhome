//
//  ProductRO.m
//  Homestyler
//
//  Created by Gil Hadas on 8/20/13.
//
//

#import "ProductRO.h"
#import "ProductItemResponse.h"
#import "AFRKHTTPRequestOperation.h"

@implementation ProductRO

////////////////////////////////////////////////////////////////////////////////////////////////////

+(void)initialize
{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getproductById:(NSString*)productID
          andVariantId:(NSString*)variantId
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    if (!productID)
        return;
    
    ApiAction *action = [[ConfigManager sharedInstance] GET_PRODUCT_BY_ID];

    if (action)
    {
        action.action = @"product/{{ID}}";
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{ID}}" withString:productID];
    }
    
    if (variantId && ![variantId isEqualToString:productID])
    {
        action.action = @"product/{{ID}}/variation/{{VID}}";
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{ID}}" withString:productID];
        action.action = [action.action stringByReplacingOccurrencesOfString:@"{{VID}}" withString:variantId];
    }
    
    [BaseRO addResponseDescriptorForPathPattern:action withMapping:[ProductItemResponse  jsonMapping]];

    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:[ConfigManager getTenantIdName] forKey:@"t"];
    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];
    
    [self getObjectsForAction:action
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getProductInfoForId:(NSArray*)productIds
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue
{
    RETURN_VOID_ON_NIL(queue);
    RETURN_VOID_ON_NIL(productIds);
    
    // At least one object is required
    if ([productIds count] == 0)
        return;
    
    self.requestQueue = queue;
    
    NSString *completeUrl = [NSString stringWithFormat:@"%@rest/v2.0/productInfo/{{ID}}?&l=en_US&t=%@&branch=%@&v=1.4",
                             [[ConfigManager sharedInstance] getNewBackendBaseUrl],
                             [ConfigManager getTenantIdName],
                             [[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""];
    
    if ([productIds objectAtIndex:0]) {
        completeUrl = [completeUrl stringByReplacingOccurrencesOfString:@"{{ID}}" withString:[productIds objectAtIndex:0]];
        
        NSURL * urlObj = [NSURL URLWithString:completeUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:urlObj];
        
        
        AFRKURLConnectionOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:request];
        
        __weak AFRKURLConnectionOperation *weakOperation = operation;
        [operation setCompletionBlock:^{
            if (completion)
            {
                
                NSError * e;
                NSData *responseData = [weakOperation responseData];
                if (responseData) {
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&e];
                    completion(json);
                }else{
                    failure(e);
                }
                
            }
        }];
        
        [operation start];
    }
}

- (void)getProductsByIds:(NSArray*)productIds
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
                   queue:(dispatch_queue_t)queue
{
    if (!queue || [productIds count] == 0) {
        completion(nil);
        return;
    }
    
    self.requestQueue = queue;
    
    NSString *completeUrl = [NSString stringWithFormat:@"%@rest/v2.0/products/{{ID}}?&l=en_US&t=%@&branch=%@&v=1.4",
                             [[ConfigManager sharedInstance] getNewBackendBaseUrl],
                             [ConfigManager getTenantIdName],
                             [[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""];
    
    NSString *commaSepereatedProductList = @"";
    for (NSString *productId in productIds)
    {
        commaSepereatedProductList = [commaSepereatedProductList stringByAppendingString:[NSString stringWithFormat:@"%@,",productId]];
    }
    
    completeUrl = [completeUrl stringByReplacingOccurrencesOfString:@"{{ID}}" withString:commaSepereatedProductList];
    
    NSURL * urlObj = [NSURL URLWithString:completeUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlObj];
    
    AFRKURLConnectionOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:request];
    
    __weak AFRKURLConnectionOperation *weakOperation = operation;
    [operation setCompletionBlock:^{
        if (completion)
        {
            NSError * e;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[weakOperation responseData]
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&e];
            completion(json);
        }
    }];
    
    [operation start];
}

@end






