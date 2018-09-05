//
//  GStreamRO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/23/13.
//
//

#import "GStreamRO.h"
#import "GetLayoutsDO.h"
#import "GalleryBanner.h"
#import "NSString+Contains.h"

@implementation GStreamRO

+(void)initialize{
    
    //  [[ConfigManager sharedInstance]getLayoutsURL]
    //  [BaseRO addResponseDescriptorForPathPattern:@"gallery/getlayouts"
    //                                  withMapping:[GalleryLayoutDO jsonMapping] isHttps:NO];
    
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]getLayoutsURL]
                                    withMapping:[GetLayoutsDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance]getItemsAtIndexURL]
                                    withMapping:[GalleryFilterDO jsonMapping]];
    
    [BaseRO addResponseDescriptorForPathPattern:[[ConfigManager sharedInstance] getBannerURL]
                                    withMapping:[GalleryBanner jsonMapping]];

}

- (void)getGalleryLayoutsWithCompletionBlock:(ROCompletionBlock)completion
                                failureBlock:(ROFailureBlock)failure
                                       queue:(dispatch_queue_t)queue{
    
    self.requestQueue=queue;
    
    [self getObjectsForAction:[[ConfigManager sharedInstance]getLayoutsURL]
                       params:[NSMutableDictionary dictionaryWithCapacity:0]
                  withHeaders:YES
              completionBlock:completion
                 failureBlock:failure];
    
}

- (void)getGalleryItemsForFilter:(GalleryFilterDO*)filter
                  withPageNumber:(int)page
             withItemsCountLimit:(int)count
             WithCompletionBlock:(ROCompletionBlock)completion
                    failureBlock:(ROFailureBlock)failure
                           queue:(dispatch_queue_t)queue{
    
    
   
    
    self.requestQueue=queue;
    
    NSMutableDictionary * params=[NSMutableDictionary dictionaryWithCapacity:0];
    
    if (filter.filterType)
        [params setObject:filter.filterType forKey:@"ft"];
    
    if (filter.roomTypeFilter)
        [params setObject:filter.roomTypeFilter forKey:@"frt"];
    
    if ([filter sortTypeToString])
        [params setObject:[filter sortTypeToString] forKey:@"s"];

    NSString * sessionId = [[UserManager sharedInstance] getSessionId];
    if (![NSString isNullOrEmpty:sessionId]) {
        [params setObject:sessionId forKey:@"sk"];
    }

    [params setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [params setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
    [self getObjectsForAction:[[ConfigManager sharedInstance]getItemsAtIndexURL]
                       params:params
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
    
}

- (void)getBanneritemsCompletionBlock:(ROCompletionBlock)completion
                        failureBlock:(ROFailureBlock)failure
                               queue:(dispatch_queue_t)queue {
    UIDevice* thisDevice = [UIDevice currentDevice];
    NSInteger deviceType = thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 5 : 6;
    NSMutableDictionary * params=[NSMutableDictionary dictionary];
    [params setObject:@(deviceType) forKey:@"type"];
    [params setObject:@"1" forKey:@"appType"];
    [self getObjectsForAction:[[ConfigManager sharedInstance]getBannerURL]
                       params:params
                  withHeaders:NO
              completionBlock:completion
                 failureBlock:failure];
}

@end
