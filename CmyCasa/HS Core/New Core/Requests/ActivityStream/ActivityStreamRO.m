//
//  ActivityStreamRO.m
//  Homestyler
//
//  Created by Avihay Assouline on 12/23/13.
//
//

#import "ActivityStreamResponse.h"
#import "ActivityStreamRO.h"

#define OFFSET_OLDER_KEY @"older"
#define OFFSET_NEWER_KEY @"newer"

///////////////////////////////////////////////////////
//               IMPLEMENTATION                      //
///////////////////////////////////////////////////////

@implementation ActivityStreamRO

+(void)initialize{
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_ACTIVITY_STREAM_PUBLIC_URL]
                                    withMapping:[ActivityStreamResponse jsonMapping]];
   
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] GET_ACTIVITY_STREAM_PRIVATE_URL]
                                    withMapping:[ActivityStreamResponse jsonMapping]];
    
}

-(void)getActivitiesForUser:(NSString*)userID
                  isPrivate:(BOOL)isPrivate
                     offset:(OffsetType)offset
            startActivityId:(NSString*)startActivityId
              numberOfItems:(NSNumber*)numberOfItems
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    // The starting activity is the activity from which the stream will start (daaa!)
    if (startActivityId != nil)
        [params setObject:startActivityId forKey:@"activityId"];
    
    // Setting the offset to newer will request newer activities starting from
    // the starting activity id. Older works in the opposite way.
    switch (offset)
    {
        case eOffsetNewer:
        {
            [params setObject:OFFSET_NEWER_KEY forKey:@"offsetType"];
        }; break;
        
        case eOffsetOlder:
        {
            [params setObject:OFFSET_OLDER_KEY forKey:@"offsetType"];
        } break;
            
        case eOffsetNone:
        default:
        {
            // Do nothing
        }
    }
    
    // Limit the size of the response
    [params setObject:numberOfItems forKey:@"limit"];
    
    if (isPrivate)
    {
        [self getObjectsForAction:[[ConfigManager sharedInstance] GET_ACTIVITY_STREAM_PRIVATE_URL]
                           params:params
                      withHeaders:YES           // Session data is required for private stream access
                  completionBlock:completion
                     failureBlock:failure];
    }
    else
    {
        // User ID is needed to get to a public URL (for private, the session key is enough)
        [params setObject:userID forKey:@"id"];
        
        [self getObjectsForAction:[[ConfigManager sharedInstance] GET_ACTIVITY_STREAM_PUBLIC_URL]
                           params:params
                      withHeaders:NO
                  completionBlock:completion
                     failureBlock:failure];
    }
    
    
}

@end
