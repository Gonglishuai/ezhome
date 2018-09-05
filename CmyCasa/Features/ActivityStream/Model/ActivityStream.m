//
//  ActivityStream.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/25/13.
//
//

#import "ActivityStreamResponse.h"
#import "ActivityStream.h"
#import "UserManager.h"


#define KEY_COMMENTS_DICTIONARY     @"_ActivityStream_key_comments_dictionary"


@interface ActivityStream ()
@property (strong, nonatomic) NSMutableArray        *activitiesCache;
@property (strong, nonatomic) NSMutableDictionary   *activitiesHash;
@property (strong, readwrite ,nonatomic) NSNumber   *itemsCount;
@property (strong, readwrite ,nonatomic) NSNumber   *offset;
@property (strong, readwrite ,nonatomic) NSString   *currentUser;
@property (strong, readwrite ,nonatomic) NSString   *currentActivityId;
@property (strong, readwrite ,nonatomic) NSDate     *lastReadDate;
@property (readwrite ,nonatomic) NSUInteger         numberOfNewActivites;
@property (nonatomic, strong) NSMutableDictionary   *commentsDictionary;
@property (nonatomic) BOOL isPrivate;
@end

@implementation ActivityStream

///////////////////////////////////////////
//     Public methods - Init             //
///////////////////////////////////////////

- (id)initWithUser:(NSString*)user isPrivate:(BOOL)isPrivate
{
    self = [super init];
    
    if (self)
    {
        self.itemsCount = [NSNumber numberWithInt:ACTIVITY_STREAM_DEFAULT_FETCH_COUNT];
        self.currentUser = user;
        self.offset = [NSNumber numberWithInt:0];
        self.activitiesCache = [[NSMutableArray alloc] initWithCapacity:0];
        self.activitiesHash = [NSMutableDictionary dictionary];
        self.isPrivate = isPrivate;
        self.numberOfNewActivites = 0;
        self.currentActivityId = nil;
        [self initCommentsDictionary];
    }
    
    return self;
}

///////////////////////////////////////////
//     Public methods                    //
///////////////////////////////////////////

- (void)getNextItemsWithSuccessAndFailureBlock:(HSCompletionBlock)successBlock failureBlock:(HSFailureBlock)failureBlock queue:(dispatch_queue_t)queue
{
    __block NSError *apiError = nil;
    
    // Checks if we already have this request in buffer. if so return it immediatly
    if (self.activitiesCache.count >= [self.offset integerValue]+[self.itemsCount integerValue])
    {
        NSRange activitiesRange = NSMakeRange(self.offset.integerValue, self.itemsCount.integerValue);
        self.offset = [NSNumber numberWithInteger:[self.offset integerValue] + [self.itemsCount integerValue]];
        successBlock( [[self.activitiesCache subarrayWithRange:activitiesRange] copy] , nil);
        return;
    }
    
    
    // The postAPICompletionBlock will update the local manager's buffer and context
    // and will launch the user's completion block
    HSCompletionBlock postActionBlock = ^(NSArray *activities, NSError *error)
    {
        // Add the results ActivityStreamDO's to the cached activities
        [self.activitiesCache addObjectsFromArray:activities];
        for (ActivityStreamDO *actDO in activities)
        {
            if ((actDO != nil) && (actDO.Id != nil))
            {
                [self.activitiesHash setObject:actDO forKey:actDO.Id];
            }
        }
        self.offset = [NSNumber numberWithInteger:[self.offset integerValue] + [activities count]];
        successBlock([activities copy], apiError); // Call the callers completion code
    };
    
    [self getItemsFromActivityStreamWithSuccessAndFailureBlock:postActionBlock failureBlock:failureBlock offset:self.offset count:self.itemsCount queue:queue];
}


- (BOOL)setActivityStreamFetchCount:(NSUInteger)count
{
    if (count > ACTIVITY_STREAM_FETCH_MAX || count < ACTIVITY_STREAM_FETCH_MIN)
        return NO;
    
    self.itemsCount = [NSNumber numberWithInteger:count];
    return YES;
}

- (void)getItemsFromActivityStreamWithSuccessAndFailureBlock:(HSCompletionBlock)successBlock failureBlock:(HSFailureBlock)failureBlock offset:(NSNumber*)offset count:(NSNumber*)count queue:(dispatch_queue_t)queue
{
    __block NSError *apiError = nil;
    
    // Checks if we already have this request in buffer. if so return it immediatly
    if (self.activitiesCache.count >= [offset integerValue] + [count integerValue])
    {
        NSRange activitiesRange = NSMakeRange(offset.integerValue, count.integerValue);
        successBlock( [self.activitiesCache subarrayWithRange:activitiesRange] , nil);
        return;
    }
    
    ROCompletionBlock postAPICompletionBlock = ^(id serverResponse)
    {
        if ( !([serverResponse isKindOfClass:[ActivityStreamResponse class]]) )
            return;
        
        ActivityStreamResponse *response = (ActivityStreamResponse*)serverResponse;
        
        self.numberOfNewActivites = response.activitiesSinceLastRead;
        self.lastReadDate = [response.lastRead copy];
        ActivityStreamDO *lastItem = [response.activities lastObject];
        self.currentActivityId = lastItem.Id;
        successBlock([response.activities copy], apiError); // Call the callers completion code
    };
    
    // Create a failure block to handle an errornous API call
    ROFailureBlock postAPIFailureBlock = ^(NSError *error)
    {
        apiError = error;
        
        failureBlock(apiError);
    };
    
    [[ActivityStreamRO new] getActivitiesForUser:self.currentUser
                                       isPrivate:self.isPrivate
                                          offset:eOffsetOlder
                                 startActivityId:self.currentActivityId
                                   numberOfItems:count
                                 completionBlock:postAPICompletionBlock
                                    failureBlock:postAPIFailureBlock
                                           queue:queue];
}

- (ActivityStreamDO*)getActivityWithId:(NSString *)activityId
{
    if (activityId != nil)
    {
        return [self.activitiesHash objectForKey:activityId];
    }
    
    return nil;
}

- (ActivityStreamDO*)getActivityAtIndex:(NSInteger)itemIdx
{
    if ([self.activitiesCache count] == 0 || [self.activitiesCache count] < itemIdx)
        return nil;
    
    // Return nil if items is of the wrong type
    if ( ![[self.activitiesCache objectAtIndex:itemIdx] isKindOfClass:[ActivityStreamDO class]])
        return nil;
    
    return [self.activitiesCache objectAtIndex:itemIdx];
}

- (void)addActivity:(ActivityStreamDO*)activity
{
    if ((activity != nil) && (activity.Id != nil))
    {
        [self.activitiesHash setObject:activity forKey:activity.Id];
    }
    
    if (activity == nil || self.activitiesCache == nil)
        return;
    
    [self.activitiesCache addObject:activity];
}

- (BOOL)resetActivityStream
{
    if (!self.activitiesCache)
        return NO;
    
    [self.activitiesCache removeAllObjects];
    [self.activitiesHash removeAllObjects];
    self.offset = [NSNumber numberWithInt:0];
    
    return YES;
}

- (void)refreshOnCacheExpiredWithSuccessAndFailureBlock:(CacheRefreshCompletionBlock)successBlock failureBlock:(CacheRefreshFailedBlock)failureBlock
{
    CacheRefreshCompletionBlock postCacheValidationBlock = ^(BOOL needRefresh)
    {
        if (needRefresh)
            [self resetActivityStream];
        
        successBlock (needRefresh);
    };
    
    [self checkCacheValidationForUser:self.currentUser
                                forAction:kCacheMyActivities
                        withCompleteBlock:postCacheValidationBlock
                             failureBlock:failureBlock
                                    queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

#pragma mark - Comments Dictionary

- (void)initCommentsDictionary
{
    self.commentsDictionary = [self getStoredCommentsDictionary];
    
    if (self.commentsDictionary == nil)
    {
        //error!!
        self.commentsDictionary = [NSMutableDictionary dictionary];
    }
}

- (NSString *)getCommentForActivityWithId:(NSString *)activityId timestamp:(NSTimeInterval)ts
{
    return [self.commentsDictionary objectForKey:[self getKeyForActivityWithId:activityId timestamp:ts]];
}

- (BOOL)setComment:(NSString *)comment forActivityWithId:(NSString *)activityId timestamp:(NSTimeInterval)ts saveToDisk:(BOOL)save
{
    if ((comment != nil) && (activityId != nil))
    {
        [self.commentsDictionary setObject:comment forKey:[self getKeyForActivityWithId:activityId timestamp:ts]];
        
        if (save == YES)
        {
            [self saveCommentsDictionary:self.commentsDictionary];
        }
        
        return YES;
    }
    
    return NO;
}

- (NSMutableDictionary *)getStoredCommentsDictionary
{
    NSMutableDictionary *plist = nil;
    NSString *path = [self getCommentsDictionaryPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError *error = nil;
        NSPropertyListFormat format;

        NSData *plistData = [NSData dataWithContentsOfFile:path];
        plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListMutableContainers format:&format error:&error];
        
        if (!plist || error)
        {
            //error
        }
    }
    else
    {
        plist = [NSMutableDictionary dictionary];
        [self saveCommentsDictionary:plist];
    }
    
    return plist;
}

- (void)saveCommentsDictionary:(NSDictionary *)dict
{
    NSError *error;
    NSString *path = [self getCommentsDictionaryPath];

    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
    if (xmlData)
    {
        [xmlData writeToFile:path atomically:YES];
    }  
}

- (NSString *)getCommentsDictionaryPath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [[path objectAtIndex:0] stringByAppendingPathComponent:@"asCommentsDictionary.plist"];
}

- (NSString *)getKeyForActivityWithId:(NSString *)activityId timestamp:(NSTimeInterval)ts
{
    int iTs = (int)ts;
    return [NSString stringWithFormat:@"%@_%d", activityId, iTs];
}

@end
