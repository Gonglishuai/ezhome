//
//  CommentsRO.h
//  Homestyler
//
//  Created by Ma'ayan on 12/4/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseRO.h"

@interface CommentsRO : BaseRO

- (void)addComment:(CommentDO *)comment forItem:(NSString *)itemId withcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue;
- (void)getCommentsForItem:(NSString *)itemId timeString:(NSString *)timeStr offset:(NSUInteger)page withcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue;

@end
