//
//  MessagesManager.h
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "BaseManager.h"

@interface MessagesManager : BaseManager

+ (MessagesManager *)sharedInstance;

@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, assign) BOOL hasNewMessages;
@property (nonatomic, assign) NSInteger currentOffset;
@property (nonatomic, strong) NSMutableArray *viewedList;
@property (nonatomic, strong) NSMutableArray *unreadList;

- (void)getMessagesCountWithCompletion:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue;

- (void)getMessagesDetailWithCompletion:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue;
- (void)getMoreMessagesDetailWithOffset:(NSInteger)offset
                             Completion:(HSCompletionBlock)completion
                                  queue:(dispatch_queue_t)queue;

- (void)setupTimer;
- (void)destoryTimer;

- (void)hadReadMessages;

@end
