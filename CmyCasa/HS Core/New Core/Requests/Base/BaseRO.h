//
//  BaseRO.h
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import <Foundation/Foundation.h>
#import "RestKit.h"
#import "ApiAction.h"
#import "RKResponseDescriptor.h"


// Completion blocks
typedef void(^ROCompletionBlock)(id serverResponse);
typedef void(^ROFailureBlock)(NSError* error);
typedef void(^HSCompletionBlock)(id serverResponse,id error);
typedef void(^HSFailureBlock)(id error);


@interface BaseRO : NSObject


+(RKObjectManager*)managerForAction:(ApiAction*)actionType withBaseUrl:(NSURL*)baseURL  andTimeout:(NSInteger)timeout;

+ (void)addResponseDescriptorForPathPattern:(ApiAction*)pattern
                                withMapping:(RKMapping*)mapping;

+ (void)addResponseDescriptor:(RKResponseDescriptor *)descriptor andApiAction:(ApiAction *)action;


+ (NSString*)sessionId;
- (NSDictionary*)generateToken:(Boolean)useSessionId;


- (void)getObjectsForAction:(ApiAction*)action
                     params:(NSMutableDictionary*)params
                withHeaders:(BOOL)headers
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure;

- (void)postWithAction:(ApiAction*)action
                params:(NSMutableDictionary*)params
           withHeaders:(BOOL)headers
             withToken:(BOOL)token
       completionBlock:(ROCompletionBlock)completion
          failureBlock:(ROFailureBlock)failure;

-(void)postWithActionAndMultiPartImages:(ApiAction*)action
                             uploadData:(NSMutableDictionary*)uploadImages
                                 params:(NSMutableDictionary*)params
                            withHeaders:(BOOL)headers
                              withToken:(BOOL)token
                        completionBlock:(ROCompletionBlock)completion
                           failureBlock:(ROFailureBlock)failure;

- (void)putWithAction:(ApiAction*)action
               params:(NSMutableDictionary*)params
          withHeaders:(BOOL)headers
            withToken:(BOOL)token
      completionBlock:(ROCompletionBlock)completion
         failureBlock:(ROFailureBlock)failure;
    
- (void)putWithAction:(ApiAction*)action
               params:(NSMutableDictionary*)params
              headers:(NSDictionary *)headers
            withToken:(BOOL)token
          completionBlock:(ROCompletionBlock)completion
             failureBlock:(ROFailureBlock)failure;

- (void)deleteWithAction:(ApiAction*)action
                  params:(NSMutableDictionary*)params
             withHeaders:(BOOL)headers
               withToken:(BOOL)token
         completionBlock:(ROCompletionBlock)completion
            failureBlock:(ROFailureBlock)failure;

@property(nonatomic,strong) NSMutableDictionary * tempRequestParams;
@property(nonatomic) dispatch_queue_t requestQueue;


@end
