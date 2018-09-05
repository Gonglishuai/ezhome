//
//  ProfessionalRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "BaseRO.h"

@interface ProfessionalRO : BaseRO




- (void)getProfessionalsByFilter:(NSString*)filtersStr
                        startIdx:(int)startIdx
                    resultsCount:(int)resultsCount
                 completionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue;


- (void)getProfessionalsByUser:(NSString*)userID
                      startIdx:(int)startIdx
                  resultsCount:(int)resultsCount
               completionBlock:(ROCompletionBlock)completion
                  failureBlock:(ROFailureBlock)failure
                         queue:(dispatch_queue_t)queue;


-(void)getProfessionalById:(NSString*)profID
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;

- (void)getProfFiltersWithCompletionBlock:(ROCompletionBlock)completion
                             failureBlock:(ROFailureBlock)failure
                                    queue:(dispatch_queue_t)queue;



-(void)followProfessional:(NSString*)professionalId
                         followStatus:(Boolean)isFollow
           completionBlock:(ROCompletionBlock)completion
              failureBlock:(ROFailureBlock)failure
                     queue:(dispatch_queue_t)queue;
@end
