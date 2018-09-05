//
//  BaseManager.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/8/13.
//
//

#import <Foundation/Foundation.h>
#import "DesignBaseClass.h"
#import "BaseRO.h"

typedef void(^CacheRefreshCompletionBlock)(BOOL needRefresh);
typedef void(^CacheRefreshFailedBlock)(NSError* error);
typedef void(^UIRefreshCompletionBlock)(void);

@interface BaseManager : NSObject <NSCoding>

@property (nonatomic, copy) NSMutableDictionary * cachedTimestamps;

-(void)initializeMyTimestamps:(NSString*)ts;

-(NSString*)getTimestampForAPIKey:(NSString*)key;

- (void)checkCacheValidationForUser:(NSString*)userid
                          forAction:(NSString*)actionKey
                  withCompleteBlock:(CacheRefreshCompletionBlock)completion
                       failureBlock:(CacheRefreshFailedBlock)failure
                              queue:(dispatch_queue_t)queue;


@end
