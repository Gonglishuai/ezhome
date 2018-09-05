//
//  GStreamRO.h
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "BaseRO.h"

@interface GStreamRO : BaseRO



- (void)getGalleryLayoutsWithCompletionBlock:(ROCompletionBlock)completion
                                failureBlock:(ROFailureBlock)failure
                                       queue:(dispatch_queue_t)queue;


- (void)getGalleryItemsForFilter:(GalleryFilterDO*)filter
                  withPageNumber:(int)page
             withItemsCountLimit:(int)count
             WithCompletionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue;

- (void)getBanneritemsCompletionBlock:(ROCompletionBlock)completion
                        failureBlock:(ROFailureBlock)failure
                               queue:(dispatch_queue_t)queue;
@end
