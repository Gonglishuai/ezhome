//
//  ActivityStream.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/25/13.
//
//

///////////////////////////////////////////////////////
//                  IMPORTS                          //
///////////////////////////////////////////////////////
#import "BaseManager.h"
#import "ActivityStreamDO.h"
#import "ActivityStreamRO.h"
#import "UserDO.h"


///////////////////////////////////////////////////////
//                  DEFINES                          //
///////////////////////////////////////////////////////
#define ACTIVITY_STREAM_DEFAULT_FETCH_COUNT (10)
#define ACTIVITY_STREAM_FETCH_MIN   (1)
#define ACTIVITY_STREAM_FETCH_MAX   (20)

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ActivityStream : BaseManager <NSCoding>

#pragma mark - Class Methods
///////////////////// Class Methods //////////////////////

// Returns an object for ActivityStreamManager
// The ActivityStream object buffers the user's activity stream.
// If isPrivate is true the stream will address the private API else it will go to the public API
- (id)initWithUser:(NSString*)user isPrivate:(BOOL)isPrivate;

// Get the next activity items
- (void)getNextItemsWithSuccessAndFailureBlock:(HSCompletionBlock)successBlock failureBlock:(HSFailureBlock)failureBlock queue:(dispatch_queue_t)queue;

// Sets the activity stream fetch count to fetch <count> items
// in each call. Is relevant when using getNextItems(). The count is
// set to ACTIVITY_STREAM_DEFAULT_FETCH_COUNT by default and is limited by
// ACTIVITY_STREAM_FETCH_MIN and ACTIVITY_STREAM_FETCH_MAX
- (BOOL)setActivityStreamFetchCount:(NSUInteger)count;

// Retrieves <count> items from the activity stream starting at a given
// index of the stream.
- (void)getItemsFromActivityStreamWithSuccessAndFailureBlock:(HSCompletionBlock)successBlock failureBlock:(HSFailureBlock)failureBlock offset:(NSNumber*)offset count:(NSNumber*)count queue:(dispatch_queue_t)queue;

// Retrieves a specific activity which is on the feed at a specific index
// The convension is that the most recent activity is indexed at 0
- (ActivityStreamDO*)getActivityAtIndex:(NSInteger)itemIdx;
- (ActivityStreamDO*)getActivityWithId:(NSString *)activityId;

// TODO: REMOVE AFTER TESTS
- (void)addActivity:(ActivityStreamDO*)activity;

// Manually resets the activity stream buffer
- (BOOL)resetActivityStream;

// Checks if we need to refresh the stream according to cache expiration policy
- (void)refreshOnCacheExpiredWithSuccessAndFailureBlock:(CacheRefreshCompletionBlock)successBlock failureBlock:(CacheRefreshFailedBlock)failureBlock;

//Return the current users' comment per an activity id if exists, otherwise return 'nil'
- (NSString *)getCommentForActivityWithId:(NSString *)activityId timestamp:(NSTimeInterval)ts;

//Report a comment that the user has made for a spesific activity id
- (BOOL)setComment:(NSString *)comment forActivityWithId:(NSString *)activityId timestamp:(NSTimeInterval)ts saveToDisk:(BOOL)save;


#pragma mark - Class properties
///////////////////// Properties //////////////////////
@property (strong, readonly ,nonatomic) NSNumber *itemsCount; // Contains the current item count to be fetched at each call (a.k.a page size)
@property (strong, readonly ,nonatomic) NSNumber *offset; // The current offset within the stream that this object is pointing at
@property (strong, readonly ,nonatomic) NSString *currentUser; // The current user for which the activities are retrieved for
@property (strong, readonly ,nonatomic) NSDate *lastReadDate; // The date in which the user last access the activity stream service
@property (readonly ,nonatomic) NSUInteger numberOfNewActivites; // Holds the number of new activites that was present in the last activities fetch request
@end
