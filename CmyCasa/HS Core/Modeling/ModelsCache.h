//
//  ModelsCache.h
//  Homestyler
//
//  Created by Avihay Assouline on 11/23/14.
//
//

#import <Foundation/Foundation.h>
#import "ModelSingleCache.h"

@interface ModelsCache : NSObject {
    dispatch_queue_t _queue;
}

@property (strong, nonatomic) NSMutableDictionary* cache;

-(NSArray*)needModel:(NSString*)modelId
         variationId:(NSString*)variationId
      andGlobalScale:(float)globalScale;

-(NSArray*)getModel:(NSString*)modelId
        variationId:(NSString*)variationId
     andGlobalScale:(float)globalScale;

-(void)releaseModel:(NSString*)modelId
     andVariationId:(NSString*)variationId;

-(void)forceDeleteModel:(NSString*)modelId;

-(void)clearCache;

@end
