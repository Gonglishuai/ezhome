//
//  FamilyRO.h
//  Homestyler
//
//  Created by Dan Baharir on 3/31/15.
//
//

#import "BaseRO.h"

@interface FamilyRO : BaseRO

-(void)getFamiliesByFamiliesIds:(NSString*)familyIds
                completionBlock:(ROCompletionBlock)completion
                   failureBlock:(ROFailureBlock)failure
                          queue:(dispatch_queue_t)queue;

@end
