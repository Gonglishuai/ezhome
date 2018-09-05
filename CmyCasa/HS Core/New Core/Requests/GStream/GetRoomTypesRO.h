//
//  GetRoomTypesRO.h
//  Homestyler
//
//  Created by Ma'ayan on 11/27/13.
//
//

#import <Foundation/Foundation.h>

#import "BaseRO.h"

@interface GetRoomTypesRO : BaseRO

- (void)getRoomTypesWithcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue;

@end
