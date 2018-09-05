//
//  GetChangedModelsRO.h
//  Homestyler
//
//  Created by Ma'ayan on 12/3/13.
//
//

#import <Foundation/Foundation.h>
#import "BaseRO.h"

@interface GetChangedModelsRO : BaseRO

- (void)getChangedModelsWithcompletionBlock:(ROCompletionBlock)completion failureBlock:(ROFailureBlock)failure queue:(dispatch_queue_t)queue;

@end
