//
//  MessagesRO.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseRO.h"

@interface MessagesRO : BaseRO

- (void)getMessagesCountCompletionBlock:(ROCompletionBlock)completion
                           failureBlock:(ROFailureBlock)failure
                                  queue:(dispatch_queue_t)queue;

- (void)getMessagesInfoWithOffSet:(NSInteger)offset
                            limit:(NSInteger)limit
                  completionBlock:(ROCompletionBlock)completion
                     failureBlock:(ROFailureBlock)failure
                            queue:(dispatch_queue_t)queue;

@end
