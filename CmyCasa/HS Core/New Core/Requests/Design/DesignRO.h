//
//  DesignRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "BaseRO.h"
#import "DesignBaseClass.h"
#import "DesignDuplicateResponse.h"
#import "DesignGetItemResponse.h"

@class SaveDesignRequestObject;
@interface DesignRO : BaseRO



- (void)designDuplicate:(NSString*)designID
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;


- (void)designChangeStatus:(NSString*)designID
            newStatus:(DesignStatus) status
        completionBlock:(ROCompletionBlock)completion
           failureBlock:(ROFailureBlock)failure
                  queue:(dispatch_queue_t)queue;

- (void)designChangeMetadata:(NSString*)designID
                 newTitle:(NSString*) title
              newDescription:(NSString*)desc
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;


- (void)designGetPrivateItem:(NSString*)designID
                     andType:(ItemType)itemType
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

- (void)designGetPublicItem:(NSString*)designID
                    andType:(ItemType)itemType
                   richData:(BOOL)richData
              withTimestamp:(NSString*)timestamp
             completionBlock:(ROCompletionBlock)completion
                failureBlock:(ROFailureBlock)failure
                       queue:(dispatch_queue_t)queue;

-(void)productListForItems:(NSArray*)uniqueItemList
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;

-(void)designLike:(NSString*)designID
    isLiked:(BOOL)like
  completionBlock:(ROCompletionBlock)completion
     failureBlock:(ROFailureBlock)failure
            queue:(dispatch_queue_t)queue;

- (void) saveDesign:(SaveDesignRequestObject*)designObject
    completionBlock:(ROCompletionBlock)completion
       failureBlock:(ROFailureBlock)failure
              queue:(dispatch_queue_t)queue;

- (void)getAssetLikes:(NSString*)assetId
             withType:(AssetItemType)assetItemType
               offset:(NSInteger)offset
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure
                queue:(dispatch_queue_t)queue;

@end
