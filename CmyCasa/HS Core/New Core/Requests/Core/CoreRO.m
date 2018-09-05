//
//  CoreRO.m
//  Homestyler
//
//  Created by Yiftach Ringel on 02/07/13.
//
//

#import "CoreRO.h"
#import "CacheTimestampResponse.h"
#import "VersionControlDO.h"

@implementation CoreRO

+ (void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetBackgrounds]
                                    withMapping:[ImagesResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] cacheValidationLink]
                                    withMapping:[CacheTimestampResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] REGISTER_DEVICE_URL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] UNREGISTER_DEVICE_URL]
                                    withMapping:[BaseResponse jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] versionCheckURL]
                                    withMapping:[VersionControlDO jsonMapping]];
}

- (void)getAppBackgroundsWithCompletionBlock:(ROCompletionBlock)completion
                                failureBlock:(ROFailureBlock)failure
{
    UIDevice* thisDevice = [UIDevice currentDevice];
    NSInteger deviceType = thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 5 : 6;
        
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetBackgrounds]
                       params:[@{@"type": @(deviceType)} mutableCopy]
                  withHeaders:NO
              completionBlock:^(id serverResponse) {
                  ImagesResponse* response = serverResponse;
                  if (completion)
                  {
                      completion(response.images);
                  }
              }
                 failureBlock:failure];
}


- (void)checkCacheValidationForUser:(NSString*)userid
                    completionBlock:(HSCompletionBlock)completion
                              queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] cacheValidationLink]
                       params:[@{@"id": userid} mutableCopy]
                  withHeaders:NO
              completionBlock:^(id serverResponse) {
                 
                  
                  if (completion) {
                      completion(serverResponse,nil);
                  }
                  
              }
                 failureBlock:^(NSError *error) {
                     NSString * erMessage=[error localizedDescription];
                     NSString *errguid=  [[HSErrorsManager sharedInstance] addErrorFromServer:[[ErrorDO alloc]initErrorWithDetails:erMessage withErrorCode:HSERR_LOCAL_ERROR_WEB_REQUEST_FAIL] withPrevGuid:nil];
                     
                     if(completion) completion(nil,errguid);
                 }];
    
   
    
}

- (void)registerDeviceForPushes:(NSString*)deviceId
                   useSessionId:(Boolean)useSessionId
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue
{
    self.requestQueue=queue;
   
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:deviceId forKey:@"deviceId"];
    [params setObject:@"IOS" forKey:@"deviceType"];
    
    NSString * nsudid=[[UserManager sharedInstance] getUniqueDeviceUserIdentifier];
    
    if (nsudid) {
        [params setObject:nsudid forKey:@"duid"];
        
    }
    
    [self postWithAction:[[ConfigManager sharedInstance] REGISTER_DEVICE_URL]
                  params:params
             withHeaders:YES
               withToken:useSessionId
         completionBlock:completion
            failureBlock:failure];

}

- (void)unregisterDeviceForPushes:(NSString*)deviceId
                   useSessionId:(Boolean)useSessionId
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue{
    
    
    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    [params setObject:deviceId forKey:@"deviceId"];
   
    NSString * nsudid=[[UserManager sharedInstance] getUniqueDeviceUserIdentifier];
    if (nsudid) {
        [params setObject:nsudid forKey:@"duid"];
        
    }
    
    [self postWithAction:[[ConfigManager sharedInstance]UNREGISTER_DEVICE_URL]
                  params:params
             withHeaders:YES
               withToken:useSessionId
         completionBlock:completion
            failureBlock:failure];
    
}

- (void)validateVersionControl:(NSString*)version ithCompletionBlock:(ROCompletionBlock)completion
                                    failureBlock:(ROFailureBlock)failure
                                           queue:(dispatch_queue_t)queue{
    
    
    
    self.requestQueue=queue;
 
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] versionCheckURL]
                       params:[@{@"type": @"1",@"buildVersion":version} mutableCopy]
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];

    
}

@end








