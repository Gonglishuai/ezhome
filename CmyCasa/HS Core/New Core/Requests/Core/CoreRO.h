//
//  CoreRO.h
//  Homestyler
//
//  Created by Yiftach Ringel on 02/07/13.
//
//

#import "BaseRO.h"
#import "ImagesInfo.h"

@interface CoreRO : BaseRO

- (void)getAppBackgroundsWithCompletionBlock:(ROCompletionBlock)completion
                                failureBlock:(ROFailureBlock)failurel;



- (void)checkCacheValidationForUser:(NSString*)userid
           completionBlock:(HSCompletionBlock)completion
                     queue:(dispatch_queue_t)queue;


- (void)registerDeviceForPushes:(NSString*)deviceId
                   useSessionId:(Boolean)useSessionId
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue;
- (void)unregisterDeviceForPushes:(NSString*)deviceId
                   useSessionId:(Boolean)useSessionId
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue;


- (void)validateVersionControl:(NSString*)version ithCompletionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue;

@end
