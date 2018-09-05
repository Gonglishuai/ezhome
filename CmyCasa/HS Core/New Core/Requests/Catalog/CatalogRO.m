//
//  CatalogRO.m
//  Homestyler
//
//
//

#import "CatalogRO.h"
#import "CategoriesResponse.h"
#import "CategoryProductsResponseOriginal.h"
#import "ConfigManager.h"

@implementation CatalogRO


+(void)initialize
{
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] NBE_GET_CATEGORIES_URL]
                                    withMapping:[CategoriesResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_CATEGORIES_URL]
                                    withMapping:[CategoriesResponse jsonMapping]];
}

-(void)getProductsByCategory:(NSString*)categoryid
                      offset:(NSNumber*)offset
                       limit:(NSNumber*)limit
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{
    
    ApiAction *action = [[ConfigManager sharedInstance] NBE_GET_PRODUCTS_BY_CATEGORY_URL];
    
    if (!categoryid && failure)
    {
        // If category ID is not defined launch the failure block
        // This shouldn't happen, it's just a guard
        failure(nil);
        return;
    }
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    // Call status with -1 to show hidden products for modellers usage
    if ([[UserManager sharedInstance] checkIfModeller]) {
        action.isCloud = NO;
        [params setValuesForKeysWithDictionary:@{@"status" : @"-1"}];
    }
    
    [BaseRO addResponseDescriptorForPathPattern:action
                                    withMapping:[CategoryProductsResponseOriginal jsonMapping]];
    
    self.requestQueue = queue;
    
    [params setObject:categoryid forKey:@"categoriesIds"];

    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenant"];

    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];

    // limit
    [params setValuesForKeysWithDictionary:@{@"limit" : [limit stringValue]}];
    
    // offset
    [params setValuesForKeysWithDictionary:@{@"offset" : [offset stringValue]}];
    
    
    [params setValuesForKeysWithDictionary:@{@"attributeIds" : @"attr-support-platform_attr-support-platform-mobile"}];
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) {
        // hot fix for ffd
        [params setValuesForKeysWithDictionary:@{@"l" : @"zh_CN"}];
    }
    
    [self getObjectsForAction:action
                       params:params withHeaders:YES
              completionBlock:completion failureBlock:failure];
    
}

-(void)getProductsByCategory:(NSString*)categoryid
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{
    
    ApiAction *action = [[ConfigManager sharedInstance] NBE_GET_PRODUCTS_BY_CATEGORY_URL];
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];

    // Call status with -1 to show hidden products for modellers usage
    if ([[UserManager sharedInstance] checkIfModeller]) {
        action.isCloud = NO;
        [params setValuesForKeysWithDictionary:@{@"status" : @"-1"}];
    }
    
    [BaseRO addResponseDescriptorForPathPattern:action
                                    withMapping:[CategoryProductsResponseOriginal jsonMapping]];
    
    self.requestQueue = queue;
    

    [params setObject:[ConfigManager getTenantIdName] forKey:@"tenat"];

    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];

    [params setObject:categoryid forKey:@"categoriesIds"];
    
    [params setValuesForKeysWithDictionary:@{@"attributeIds" : @"attr-support-platform_attr-support-platform-mobile"}];
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) {
        //hot fix for ffd
        [params setValuesForKeysWithDictionary:@{@"l" : @"zh_CN"}];
    }
    
    [self getObjectsForAction:action
                       params:params withHeaders:YES
              completionBlock:completion failureBlock:failure];
}


-(void)getProductsBySearchString:(NSString*)searchString
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue
{
    
    self.requestQueue = queue;
    
    NSString *completeUrl = [NSString stringWithFormat:@"%@rest/v3.0/products/search?t=%@&tenant=%@&branch=%@&v=1.4",
                             [[ConfigManager sharedInstance] getNewBackendBaseUrl],
                             searchString,
                             [ConfigManager getTenantIdName],
                             [[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""];
    
    completeUrl = [completeUrl stringByAppendingString:@"&attributeIds=attr-support-platform_attr-support-platform-mobile&l=zh_CN"];

    
    // Call status with -1 to show hidden products for modellers usage
    if ([[UserManager sharedInstance] checkIfModeller]) {
        completeUrl = [completeUrl stringByAppendingString:@"&status=-1"];
    }
    completeUrl = [completeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * urlObj = [NSURL URLWithString:completeUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlObj];
    
    AFRKURLConnectionOperation *operation = [[AFRKHTTPRequestOperation alloc] initWithRequest:request];
    
    __weak AFRKURLConnectionOperation *weakOperation = operation;
    [operation setCompletionBlock:^{
        if (completion)
        {
            
            NSError * e;
            if ([weakOperation responseData]) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[weakOperation responseData]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&e];
                completion(json);
            }else{
                 failure(nil);
            }
        }
    }];
    
    [operation start];

}



-(void)getRootCategoriesWithcompletionBlock:(ROCompletionBlock)completion
                               failureBlock:(ROFailureBlock)failure
                                      queue:(dispatch_queue_t)queue{
    
    [self getCategoriesForLevel:nil completionBlock:completion failureBlock:failure queue:queue];
}


-(void)getCategoriesForLevel:(NSString*)categoryid
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue{

    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    if (categoryid) {
        [params setObject:categoryid forKey:@"c"];
    }
    
    [params setObject:[ConfigManager getTenantIdName] forKey:@"t"];
    
    [params setObject:[[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""  forKey:@"branch"];
    
    [params setObject:@"photo" forKey:@"app"];
    
    [params setValuesForKeysWithDictionary:@{@"attributeIds" : @"attr-support-platform_attr-support-platform-mobile"}];
 
    if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]) {
        [params setValuesForKeysWithDictionary:@{@"l" : @"zh_CN"}];
    }
    ApiAction *action = [[ConfigManager sharedInstance] NBE_GET_CATEGORIES_URL];
    
    // Call status with -1 to show hidden products for modellers usage
    if ([[UserManager sharedInstance] checkIfModeller]) {
        action.isCloud = NO;
        [params setValuesForKeysWithDictionary:@{@"status" : @"-1"}];
        
        [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] NBE_GET_CATEGORIES_URL]
                                        withMapping:[CategoriesResponse jsonMapping]];
    }
    
    [self getObjectsForAction:action
                       params:params withHeaders:YES
              completionBlock:completion failureBlock:failure];
}

@end
