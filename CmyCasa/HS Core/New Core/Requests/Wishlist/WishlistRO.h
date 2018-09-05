//
//  WishlistRO.h
//  Homestyler
//
//
//

#import "BaseRO.h"

@interface WishlistRO : BaseRO

-(void)getWishListByEmailString:(NSString*)email
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue;

-(void)getProductForWishListId:(NSString*)wishListId
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue;

-(void)getWishListUserIdForEmail:(NSString*)email
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue;

-(void)createNewWishListName:(NSString*)wishListName
                 withProduct:(NSString*)productSku
          withWishListUserId:(NSString*)wishListUserId
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)addProductToWishListId:(NSString*)wishListId
                 withProduct:(NSString*)productSku
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)getCompleteWishListsForEmail:(NSString*)email
                    completionBlock:(ROCompletionBlock)completion
                       failureBlock:(ROFailureBlock)failure
                              queue:(dispatch_queue_t)queue;

-(void)deleteWishList:(NSString*)wishListId
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
                queue:(dispatch_queue_t)queue;

-(void)updateProductToWishLists:(NSArray*)wishLists
                  withProduct:(NSString*)productSku
                    operation:(OperationType)operationType
              completionBlock:(ROCompletionBlock)completion
                 failureBlock:(ROFailureBlock)failure
                        queue:(dispatch_queue_t)queue;

@end
