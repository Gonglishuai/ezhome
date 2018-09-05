//
//  VersionControlDO.m
//  Homestyler
//
//  Created by Berenson Sergei on 7/31/13.
//
//

#import "VersionControlDO.h"

@implementation VersionControlDO


+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping* entityMapping = [super jsonMapping];
    
    // Add assets mapping
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"available_update" : @"versionUpdateExists",
     @"must_upate" : @"versionUpdateRequired",
     }];

    
    return entityMapping;
}

@end
