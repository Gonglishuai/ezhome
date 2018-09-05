//
//  ModelsCache.m
//  Homestyler
//
//  Created by Avihay Assouline on 11/23/14.
//
//

#import "ModelsCache.h"
#import "HSMacros.h"

@implementation ModelsCache

static int compressFactor = 1;

-(instancetype)init
{
    if (self = [super init])
    {
        self.cache = [[NSMutableDictionary alloc] init];
        _queue = dispatch_queue_create("com.autodesk.modelscache", DISPATCH_QUEUE_CONCURRENT);
        
        compressFactor = 1;
    }
    
    return self;
}

-(NSArray*)needModel:(NSString*)modelId
         variationId:(NSString*)variationId
      andGlobalScale:(float)globalScale
{
    RETURN_ON_NIL(modelId, nil);

    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", modelId, variationId];
    
    // (1) Look for the model in the local cache
    __block ModelSingleCache* modelCache = nil;
    dispatch_sync(_queue, ^{
        modelCache = self.cache[cacheKey];
    });
    
    // (2) If model was not found, init the model and place it in the cache.
    if (!modelCache) {
        dispatch_barrier_sync(_queue, ^{
            modelCache = [[ModelSingleCache alloc] initWithModelId:modelId
                                                       variationId:variationId
                                                             queue:_queue];
            if (modelCache)
                self.cache[cacheKey] = modelCache;
        });
    }
    
    // (3) If we failed to initialize the model, return nil.
    // This can occur only on memory issues
    RETURN_ON_NIL(modelCache, nil);
    
    [modelCache loadWithGlobalScale:globalScale
             andCompressFactor:compressFactor];
    
    if (!modelCache || !modelCache.mesh || !modelCache.texInfo || !modelCache.metadata) {
        NSLog(@"missing modelCache.texInfo modelCache.metadata");
        return nil;
    }
    
    return @[modelCache.mesh, modelCache.texInfo, modelCache.metadata];
}

-(NSArray*)getModel:(NSString *)modelId
        variationId:(NSString *)variationId
     andGlobalScale:(float)globalScale
{
    RETURN_ON_NIL(modelId, nil);
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", modelId, variationId];
    
    // (1) Look for the model in the local cache
    __block ModelSingleCache* modelCache = nil;
    dispatch_sync(_queue, ^{
        modelCache = self.cache[cacheKey];
    });
    
    // (2) If model was not found, init the model and place it in the cache.
    if (!modelCache) {
        dispatch_barrier_sync(_queue, ^{
            modelCache = [[ModelSingleCache alloc] initWithModelId:modelId
                                                       variationId:variationId
                                                             queue:_queue];
            if (modelCache)
                self.cache[cacheKey] = modelCache;
        });
    }
    
    // (3) If we failed to initialize the model, return nil.
    // This can occur only on memory issues
    RETURN_ON_NIL(modelCache, nil);

    NSArray* res = [modelCache loadModelComponentsFromZipWithGlobalScale:globalScale
                                        andCompressFactor:compressFactor];
    
    if (res.count == 0) {
        NSLog(@"missing modelCache.texInfo modelCache.metadata");
        return nil;
    }

    return @[res[3], res[2], res[1]];
}

-(void)releaseModel:(NSString*)modelId
     andVariationId:(NSString*)variationId
{
    RETURN_VOID_ON_NIL(modelId);
    
    __block ModelSingleCache* model = nil;
    
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", modelId, variationId];
    
    dispatch_sync(_queue, ^{
        model = self.cache[cacheKey];
    });
    
    if (model) {
        dispatch_barrier_sync(_queue, ^{
            [model unload];
            if (model.count <= 0) {
                [self.cache removeObjectForKey:cacheKey];
            }
        });
    }
    
}
-(void)forceDeleteModel:(NSString*)modelId {
    dispatch_barrier_sync(_queue, ^{
        if (self.cache) [self.cache removeObjectForKey:modelId];
    });
}
-(void)clearCache {
    dispatch_barrier_sync(_queue, ^{
        if (self.cache) [self.cache removeAllObjects];
    });
}

-(void)dealloc {
    self.cache = nil;
}

@end
