//
//  ActivityStreamRO.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/23/13.
//
//

#import "BaseRO.h"

typedef enum OffsetType_t
{
    eOffsetNone = 0,
    eOffsetNewer,
    eOffsetOlder
} OffsetType;

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ActivityStreamRO : BaseRO

-(void)getActivitiesForUser:(NSString*)userID
                  isPrivate:(BOOL)isPrivate
                     offset:(OffsetType)offset
            startActivityId:(NSString*)startActivityId
              numberOfItems:(NSNumber*)numberOfItems
            completionBlock:(ROCompletionBlock)completion
               failureBlock:(ROFailureBlock)failure
                      queue:(dispatch_queue_t)queue;

@end
