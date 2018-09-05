//
//  MessageCenterRO.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "MessagesRO.h"
#import "MessagesResponse.h"
#import "NSString+Contains.h"

@implementation MessagesRO

+ (void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getMessagesInfo]
                                    withMapping:[MessagesResponse jsonMapping]];

}

- (void)getMessagesCountCompletionBlock:(ROCompletionBlock)completion
                           failureBlock:(ROFailureBlock)failure
                                  queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString * sessionId = [[UserManager sharedInstance] getSessionId];
    if (![NSString isNullOrEmpty:sessionId]) {
        [params setObject:sessionId forKey:@"s"];
    }
    [params setObject:@"false" forKey:@"rich"];
    [self getObjectsForAction:[[ConfigManager sharedInstance] getMessagesInfo]
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];

}

- (void)getMessagesInfoWithOffSet:(NSInteger)offset
                            limit:(NSInteger)limit
                  completionBlock:(ROCompletionBlock)completion
                     failureBlock:(ROFailureBlock)failure
                            queue:(dispatch_queue_t)queue;
{
    self.requestQueue = queue;
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString * sessionId = [[UserManager sharedInstance] getSessionId];
    if (![NSString isNullOrEmpty:sessionId]) {
        [params setObject:sessionId forKey:@"s"];
    }
    [params setObject:@(offset) forKey:@"offset"];
    [params setObject:@(limit) forKey:@"limit"];
    [params setObject:@"true" forKey:@"rich"];
    [self getObjectsForAction:[[ConfigManager sharedInstance] getMessagesInfo]
                       params:params
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
}

@end
