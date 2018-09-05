//
//  GalleryFilterExtraDO.m
//  Homestyler
//
//  Created by liuyufei on 4/25/18.
//

#import "GalleryFilterExtraDO.h"

@implementation GalleryFilterExtraDO

+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping *entityMapping = [RKObjectMapping mappingForClass:[self class]];

    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"followingCount" : @"followingCount",
       }];
    return entityMapping;
}

@end
