//
//  WishlistHandler.h
//  Homestyler
//
//  Created by Tomer Har Yoffi.
//
//

#import <Foundation/Foundation.h>
#import "ProtocolsDef.h"

@interface WishlistHandler : NSObject

+ (id)sharedInstance;

- (BOOL)isReveseMapReady;
- (NSArray*)getWishlist;
- (NSDictionary*)getProductToWishlistsDict;

//not use
//- (void)getWishListForUserEmail:(NSString*)email
//            withCompletionBlock:(HSCompletionBlock)completion
//                          queue:(dispatch_queue_t)queue;

- (void)getProductsForWishListId:(NSString*)wishListId
            withCompletionBlock:(HSCompletionBlock)completion
                          queue:(dispatch_queue_t)queue;

-(void)getWishListUserIdForEmail:(NSString*)email
             withCompletionBlock:(HSCompletionBlock)completion
                           queue:(dispatch_queue_t)queue;

-(void)createNewWishListName:(NSString*)wishListName
                 withProduct:(NSString*)productSku
          withWishListUserId:(NSString*)wishListUserId
         withCompletionBlock:(HSCompletionBlock)completion
                       queue:(dispatch_queue_t)queue;

//not use
//-(void)addProductToWishListId:(NSString*)wishListId
//                 withProduct:(NSString*)productSku
//         withCompletionBlock:(HSCompletionBlock)completion
//                       queue:(dispatch_queue_t)queue;

-(void)getCompleteWishListsForEmail:(NSString*)email
                withCompletionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue;

-(void)deleteWishlist:(NSString*)wishListId
  withCompletionBlock:(HSCompletionBlock)completion
                queue:(dispatch_queue_t)queue;

-(void)updateProductToWishLists:(NSArray*)wishLists
                 withProductSku:(NSString*)productSku
                  withProductId:(NSString*)productId
                      operation:(OperationType)operationType
            withCompletionBlock:(HSCompletionBlock)completion
                          queue:(dispatch_queue_t)queue;

@end
