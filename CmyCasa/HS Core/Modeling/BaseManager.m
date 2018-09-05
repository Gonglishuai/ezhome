//
//  BaseManager.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/8/13.
//
//

#import "BaseManager.h"
#import "CacheTimestampResponse.h"
#import "CoreRO.h"


@interface BaseManager ()

-(NSString*)getTimestampForAction:(NSString *)action;

@end

@implementation BaseManager


-(id)init{
    self = [super init];
    if (self) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"api_cache_timestamps"]!=nil) {
            id defaults=[[NSUserDefaults standardUserDefaults] objectForKey:@"api_cache_timestamps"];
            
            if ([defaults isKindOfClass:[NSMutableDictionary class]]) {
                self.cachedTimestamps=defaults;
            }else{
                self.cachedTimestamps=[[NSMutableDictionary alloc] init];
            }
        }else{
            self.cachedTimestamps=[[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

#pragma mark Cache Management
-(void)initializeMyTimestamps:(NSString*)ts{
    //no implementaion
}

- (void)checkCacheValidationForUser:(NSString*)userid
                          forAction:(NSString*)actionKey
                  withCompleteBlock:(CacheRefreshCompletionBlock)completion
                       failureBlock:(CacheRefreshFailedBlock)failure
                              queue:(dispatch_queue_t)queue
{
    
    if (userid==nil || actionKey==nil) {
        completion(YES);
        return;
    }
    
    HSMDebugLog(@"Cache CHECK for user %@ action %@",userid,actionKey);
    
    [[CoreRO new]checkCacheValidationForUser:userid completionBlock:^(id serverResponse, id error) {
        
        BOOL needRefresh=NO;
        CacheTimestampResponse * cacheResponse=nil;
        if (error==nil) {
            cacheResponse=(CacheTimestampResponse*)serverResponse;
            
            if (![self getTimestampForAction:actionKey]) {
                //when no timestamps were saved before same them the first time
                
                NSMutableDictionary * tmpDict = [self.cachedTimestamps mutableCopy];
                [tmpDict setObject:[NSString  stringWithFormat:@"%ld", (long)cacheResponse.timestamp] forKey:actionKey];
                [self setCachedTimestamps:tmpDict];
                
                [[NSUserDefaults standardUserDefaults]setObject:self.cachedTimestamps forKey:@"api_cache_timestamps"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
                needRefresh= ![self compareTimestamps:[self getTimestampForAction:actionKey]
                                       withRemoteTime:[NSString  stringWithFormat:@"%ld", (long)cacheResponse.timestamp]];
            
        }else{
            
            needRefresh=YES;
        }
        
        if (needRefresh) {
            NSString * value = [NSString  stringWithFormat:@"%ld", (long)cacheResponse.timestamp];
            NSMutableDictionary *tmpDict = [self.cachedTimestamps mutableCopy];
            [tmpDict setObject:value forKey:actionKey];

            [self setCachedTimestamps:tmpDict];
            [[NSUserDefaults standardUserDefaults]setObject:self.cachedTimestamps forKey:@"api_cache_timestamps"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        HSMDebugLog(@"SERVER CACHE CHECK FOR KEY %@ need refresh=%d",actionKey,needRefresh);
        completion(needRefresh);
    } queue:queue];
}

-(BOOL)compareTimestamps:(NSString*)localTime withRemoteTime:(NSString*)remoteTime{
    
    NSDate * localdt=nil;
    NSDate * remotedt=nil;
    
    if (localTime) {
        localdt=[NSDate dateWithTimeIntervalSince1970:[localTime integerValue]];
    }
    
    if (remoteTime) {
        remotedt=[NSDate dateWithTimeIntervalSince1970:[remoteTime integerValue]];
    }
    
    if (localdt && remotedt) {
        
        if ([remotedt isEqualToDate:localdt])
            return YES;
        else
            return NO;
    }else{
        return YES;
    }
}


-(BOOL)checkTimestampExistanceForAction:(NSString*)action{
    
    if (action==nil) {
        return NO;
    }
    
    if (self.cachedTimestamps==nil) {
        self.cachedTimestamps=[[NSMutableDictionary alloc] init];
        return NO;
    }
    
    if ([self.cachedTimestamps objectForKey:action]) {
        return YES;
    }
    
    return NO;
}

-(NSString*)getTimestampForAPIKey:(NSString*)key{
    
    return [self getTimestampForAction:key];
}

-(NSString*)getTimestampForAction:(NSString *)action{
    
    if ([self checkTimestampExistanceForAction:action]) {
        return [self.cachedTimestamps objectForKey:action];
    }
    
    return nil;
}

@end
