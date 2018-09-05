//
//  ImagesInfo.h
//  Homestyler
//
//  Created by Yiftach Ringel on 02/07/13.
//
//

#import "ImagesInfo.h"

@implementation ImagesResponse

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"Images"
                                                 toKeyPath:@"images"
                                               withMapping:[ImageInfo jsonMapping]]];
    
    return entityMapping;
}
- (void)applyPostServerActions
{
    
}
//- (void)applyPostServerActions
//{
//    ImageInfo* newImage = [ImageInfo new];
//    newImage.url = @"http://hsm-designs.s3.amazonaws.com/D66FVxNK14/i_63bd3221-c3e7-428a-803c-57b1cfc13f37.jpg";
//    self.images = @[self.images[0], newImage];
//}

@end

@implementation ImageInfo

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"id" : @"imageId",
     @"url" : @"url",
     }];
    
    return entityMapping;
}

@end
