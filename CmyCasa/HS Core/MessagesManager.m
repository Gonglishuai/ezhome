//
//  MessagesManager.m
//  Homestyler
//
//  Created by liuyufei on 5/1/18.
//

#import "MessagesManager.h"
#import "MessagesResponse.h"
#import "MessagesRO.h"
#import "MessagesCountDO.h"
#import "NotificationDetailDO.h"

static const CGFloat Messages_limit = 50;

static NSString *const Bubble_Follow_Icon = @"notification_follow";
static NSString *const Bubble_Like_Icon = @"notification_like";
static NSString *const Bubble_Comment_Icon = @"notification_comment";
static NSString *const Bubble_Feature_Icon = @"notification_featured";
static NSString *const Bubble_Info_Icon = @"notification_info";

static NSString *const Bubble_Info_MessagesManager_Count = @"MessagesManager_Count";

@interface MessagesManager()

@property (nonatomic, assign) NSInteger cachedMessagesCount;

@property (nonatomic, strong) NSMutableDictionary *messagesDict;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MessagesManager

static MessagesManager *sharedInstance = nil;

+ (MessagesManager *)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[MessagesManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init])
    {

    }
    return self;
}

- (NSMutableDictionary *)messagesDict
{
    if (!_messagesDict)
    {
        _messagesDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _messagesDict;
}

- (NSMutableArray *)unreadList
{
    if (!_unreadList)
    {
        _unreadList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _unreadList;
}

- (NSMutableArray *)viewedList
{
    if (!_viewedList)
    {
        _viewedList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _viewedList;
}

- (void)getMessagesCountWithCompletion:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    [[MessagesRO new] getMessagesCountCompletionBlock:^(MessagesResponse *response) {
        if (response.errorCode == -1)
        {
             MessagesCountDO *messagesCount = (MessagesCountDO *)response.countOfTypes;
            [self saveMessagesCount:messagesCount];
            if (completion)
            {
                completion(messagesCount,nil);
            }
        }
        if (completion) {
            completion(nil,response.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString *erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];

        if(completion) completion(nil,errguid);
    } queue:queue];
}

- (void)getMessagesDetailWithCompletion:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    self.isLoaded = NO;
    self.hasMoreData = YES;
    self.currentOffset = 0;
    [self.viewedList removeAllObjects];
    [self.unreadList removeAllObjects];
    __weak typeof(self) weakSelf = self;
    [[MessagesRO new] getMessagesInfoWithOffSet:self.currentOffset limit:Messages_limit completionBlock:^(MessagesResponse *response) {
        weakSelf.isLoaded = YES;
        if (response.errorCode == -1)
        {
            if (response.noticeList.count == 0)
            {
                weakSelf.hasMoreData = NO;
            }
            weakSelf.currentOffset = response.noticeList.count;
            if (completion)
            {
                completion([weakSelf updateMessagesDetail:response],nil);
            }
        }
        else
        {
            if (completion) {
                completion(nil,response.hsLocalErrorGuid);
            }
        }
    } failureBlock:^(NSError *error) {
        NSString *erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance]
                             addErrorFromServer:[[ErrorDO alloc] initErrorWithDetails:erMessage
                                                                        withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL]
                             withPrevGuid:nil];
        if(completion) completion(nil,errguid);
    } queue:queue];
}

- (void)getMoreMessagesDetailWithOffset:(NSInteger)offset
                             Completion:(HSCompletionBlock)completion
                                  queue:(dispatch_queue_t)queue
{
    __weak typeof(self) weakSelf = self;
    [[MessagesRO new] getMessagesInfoWithOffSet:offset limit:Messages_limit completionBlock:^(MessagesResponse *response) {
        if (response.errorCode == -1)
        {
            if (response.noticeList.count == 0)
            {
                weakSelf.hasMoreData = NO;
            }
            weakSelf.currentOffset += response.noticeList.count;
            if (completion)
            {
                completion([weakSelf updateMessagesDetail:response],nil);
            }
        }
        if (completion) {
            completion(nil,response.hsLocalErrorGuid);
        }
    } failureBlock:^(NSError *error) {
        NSString *erMessage = [error localizedDescription];
        NSString *errguid = [[HSErrorsManager sharedInstance]
                             addErrorFromServer:[[ErrorDO alloc] initErrorWithDetails:erMessage
                                                                        withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL]
                             withPrevGuid:nil];
        if(completion) completion(nil,errguid);
    } queue:queue];
}

- (NSMutableArray *)updateMessagesDetail:(MessagesResponse *)detail
{
    __block NSMutableArray *messageList = [[NSMutableArray alloc] initWithCapacity:0];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSString *lastViewTimestamp = detail.lastViewTime;
    NSTimeInterval lastViewInterval = [lastViewTimestamp doubleValue] / 1000.0;
    NSDate *zoneDate = [NSDate dateWithTimeIntervalSince1970:lastViewInterval];
    NSDate *lastViewDate = [zoneDate dateByAddingTimeInterval:[zone secondsFromGMT]];
    [detail.noticeList enumerateObjectsUsingBlock:^(NotificationDetailDO *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *createTimestamp = obj.createTime;
        NSTimeInterval createTimeInterval = [createTimestamp doubleValue] / 1000.0;
        NSDate *zoneCreateTimeDate = [NSDate dateWithTimeIntervalSince1970:createTimeInterval];
        NSDate *createTimeDate = [zoneCreateTimeDate dateByAddingTimeInterval:[zone secondsFromGMT]];
        NSComparisonResult result = [lastViewDate compare:createTimeDate];
        if (result == NSOrderedAscending)
        {
            [self.unreadList addObject:obj];
        }
        else
        {
            [self.viewedList addObject:obj];
        }
    }];
    [messageList addObject:self.viewedList];
    [messageList addObject:self.unreadList];
    return messageList;
}

#pragma mark - get all messages
- (void)setupTimer
{
    if (self.timer)
        return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(receiveUserMessages) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)destoryTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)receiveUserMessages
{
    __weak typeof(self) weakSelf = self;
    [[MessagesManager sharedInstance] getMessagesCountWithCompletion:^(MessagesCountDO *item, id error) {
        if (item)
        {
            if (item.allCount > 0 && item.allCount != weakSelf.cachedMessagesCount)
            {
                NSArray *messages = [weakSelf setupMessages:item];
                weakSelf.hasNewMessages = YES;
                NSDictionary *items = @{@"messages" : messages};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getAllUserMessages" object:nil userInfo:items];
            }
        }
    } queue:dispatch_get_main_queue()];
}

- (void)saveMessagesCount:(MessagesCountDO *)messagesCount
{
    self.cachedMessagesCount = [[self.messagesDict objectForKey:Bubble_Info_MessagesManager_Count] integerValue];
    [self.messagesDict setObject:@(messagesCount.allCount) forKey:Bubble_Info_MessagesManager_Count];
}

- (NSArray *)setupMessages:(MessagesCountDO *)item
{
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:0];
    if (item.followingCount > 0)
    {
        NSMutableDictionary *follow = [[NSMutableDictionary alloc] initWithCapacity:0];
        [follow setObject:Bubble_Follow_Icon forKey:@"icon"];
        [follow setObject:@(item.followingCount) forKey:@"count"];
        [messages addObject:follow];
    }
    if (item.likeCount > 0)
    {
        NSMutableDictionary *like = [[NSMutableDictionary alloc] initWithCapacity:0];
        [like setObject:Bubble_Like_Icon forKey:@"icon"];
        [like setObject:@(item.likeCount) forKey:@"count"];
        [messages addObject:like];
    }
    if (item.commentsCount > 0)
    {
        NSMutableDictionary *comment = [[NSMutableDictionary alloc] initWithCapacity:0];
        [comment setObject:Bubble_Comment_Icon forKey:@"icon"];
        [comment setObject:@(item.commentsCount) forKey:@"count"];
        [messages addObject:comment];
    }
    if (item.featuredCount > 0)
    {
        NSMutableDictionary *featured = [[NSMutableDictionary alloc] initWithCapacity:0];
        [featured setObject:Bubble_Feature_Icon forKey:@"icon"];
        [featured setObject:@(item.featuredCount) forKey:@"count"];
        [messages addObject:featured];
    }
    if (item.otherCount > 0)
    {
        NSMutableDictionary *other = [[NSMutableDictionary alloc] initWithCapacity:0];
        [other setObject:Bubble_Info_Icon forKey:@"icon"];
        [other setObject:@(item.otherCount) forKey:@"count"];
        [messages addObject:other];
    }
    return messages;
}

- (void)hadReadMessages
{
    self.hasNewMessages = NO;
}

@end
