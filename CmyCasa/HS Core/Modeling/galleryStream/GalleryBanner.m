//
//  GalleryBanner.m
//  EZHome
//
//  Created by xiefei on 31/10/17.
//

#import "GalleryBanner.h"

@implementation GalleryBanneItem
+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"link" : @"link",
       @"image" : @"image",
       }];
    
    return entityMapping;
}
@end

@implementation GalleryBanner
+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    // Add assets mapping
    [entityMapping addPropertyMapping:
     [RKRelationshipMapping relationshipMappingFromKeyPath:@"image_link"
                                                 toKeyPath:@"image_link"
                                               withMapping:[GalleryBanneItem jsonMapping]]];
    
    return entityMapping;
}
@end
