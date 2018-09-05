//
//  ModelSingleCache.h
//  Homestyler
//
//  Created by Avihay Assouline on 11/23/14.
//
//

#import <Foundation/Foundation.h>

@interface ModelSingleCache : NSObject
{
    dispatch_queue_t _queue;
}

@property (strong, nonatomic) NSString* modelId;
@property (strong, nonatomic) NSString* variationId;
@property (strong, nonatomic) GraphicObject* mesh;
@property (strong, nonatomic) GLKTextureInfo* texInfo;
@property (strong, nonatomic) NSDictionary* metadata;
@property (assign, atomic) NSUInteger count;

/*
 *
 */
-(id)initWithModelId:(NSString*)modelId
         variationId:(NSString*)variationId
               queue:(dispatch_queue_t)queue;

/*
 *
 */
-(void)loadWithGlobalScale:(float)globalScale
         andCompressFactor:(int)compressFactor;

/*
 *
 */
-(void)unload;
//- (NSDictionary*) extractModelZip2;
//- (NSDictionary*) extractModelZip:(NSString*)modelId;

- (NSArray*)loadModelComponentsFromZipWithGlobalScale:(float)globalScale
                                    andCompressFactor:(int)compressFactor;

@end
