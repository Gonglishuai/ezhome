//
//  FamilyRO.m
//  Homestyler
//
//  Created by Dan Baharir on 3/31/15.
//
//

#import "FamilyRO.h"
#import "AFRKHTTPRequestOperation.h"

@implementation FamilyRO

-(void)getFamiliesByFamiliesIds:(NSString*)familyIds
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue{
   
    if (!familyIds && failure){
        // If category ID is not defined launch the failure block
        // This shouldn't happen, it's just a guard
        failure(nil);
        return;
    }
    
    self.requestQueue = queue;
    
    NSString *completeUrl = [NSString stringWithFormat:@"%@rest/v2.0/familyByIds?ids=%@&l=en_US&t=%@&branch=%@&v=1.4",
                             [[ConfigManager sharedInstance] getNewBackendBaseUrl],
                             familyIds,
                             [ConfigManager getTenantIdName],
                             [[ConfigManager sharedInstance] countySymbol] ? [[ConfigManager sharedInstance] countySymbol] : @""];

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
