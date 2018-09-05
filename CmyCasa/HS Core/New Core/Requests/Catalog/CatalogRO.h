//
//  CatalogRO.h
//  Homestyler
//
//
//

#import "BaseRO.h"

@interface CatalogRO : BaseRO

-(void)getProductsByCategory:(NSString*)categoryid
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)getProductsByCategory:(NSString*)categoryid
                      offset:(NSNumber*)offset
                       limit:(NSNumber*)limit
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)getRootCategoriesWithcompletionBlock:(ROCompletionBlock)completion
                               failureBlock:(ROFailureBlock)failure
                                      queue:(dispatch_queue_t)queue;

-(void)getCategoriesForLevel:(NSString*)categoryid
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)getProductsBySearchString:(NSString*)searchString
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue;

@end
