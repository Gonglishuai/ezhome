//
//  GetRoomTypesRO.m
//  Homestyler
//
//  Created by Ma'ayan on 11/27/13.
//
//

#import "GetRoomTypesRO.h"
#import "GetRoomTypesResponse.h"

@implementation GetRoomTypesRO

+ (void)initialize
{
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] actionGetRoomTypes]
                                    withMapping:[GetRoomTypesResponse jsonMapping]];
}

- (void)getRoomTypesWithcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue
{
    self.requestQueue = queue;
    
    [self getObjectsForAction:[[ConfigManager sharedInstance] actionGetRoomTypes] params:nil withHeaders:NO completionBlock:^(id serverResponse)
    {
                  GetRoomTypesResponse* response = serverResponse;
        
                  if (completion != nil)
                  {
                      if (response.roomTypes != nil)
                      {
                          completion(response.roomTypes);
                      }
                  }
              } failureBlock:failure];
}

@end
