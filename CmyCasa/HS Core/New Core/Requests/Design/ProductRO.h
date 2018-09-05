//
//  ProductRO.h
//  Homestyler
//
//  Created by Gil Hadas on 8/20/13.
//
//
#import "BaseRO.h"

@interface ProductRO : BaseRO

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getproductById:(NSString*)productID
          andVariantId:(NSString*)variantId
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure
                 queue:(dispatch_queue_t)queue;

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getProductInfoForId:(NSArray*)productIds
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue;

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getProductsByIds:(NSArray*)productIds
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure
                   queue:(dispatch_queue_t)queue;

@end








