//
//  GetChangedModelsRO.m
//  Homestyler
//
//  Created by Ma'ayan on 12/3/13.
//
//

#import "GetChangedModelsRO.h"
#import "GetChangedModelsResponse.h"
#import "HelpersRO.h"

@implementation GetChangedModelsRO

+ (void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetChangedModels]
                                    withMapping:[GetChangedModelsResponse jsonMapping]];
}

- (void)getChangedModelsWithcompletionBlock:(ROCompletionBlock)completion
                               failureBlock:(ROFailureBlock)failure
                                      queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    NSString *lastModelsUpdateTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastModelsUpdateTime"];
    NSDate *midnightUTC = [HelpersRO getMidnightUTC];

    if (lastModelsUpdateTime == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[HelpersRO getUTCFormateDate:midnightUTC] forKey:@"lastModelsUpdateTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if (completion != nil)
        {
            completion(nil);
        }
        
        return;
    }
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetChangedModels] params:[@{@"t": lastModelsUpdateTime} mutableCopy] withHeaders:NO completionBlock:^(id serverResponse)
     {
         GetChangedModelsResponse *response = (GetChangedModelsResponse *) serverResponse;
         
         if (response != nil)
         {
             BOOL isSuccess = ([response errorCode] == -1);
             
             if (isSuccess)
             {
                 NSArray *models = response.models;
                 
                 if (completion != nil)
                 {
                     completion(models);
                 }
             }
             else
             {
                 if (completion != nil)
                 {
                     completion(nil);
                 }
                 
                 HSMDebugLog(@"getChangedModelsWithcompletionBlock error code %ld", (long)[response errorCode]);
             }
         }
         else
         {
             if (completion != nil)
             {
                 completion(nil);
             }
             
             HSMDebugLog(@"getChangedModelsWithcompletionBlock error - server response is nil");
         }
     } failureBlock:^ (NSError* error)
     {
         if (failure != nil)
         {
             failure(error);
         }
         
         HSMDebugLog(@"getChangedModelsWithcompletionBlock error - %@", error.localizedDescription);
     }];
}

@end
