//
//  CacheTimestampResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/30/13.
//
//

#import "CacheTimestampResponse.h"

@implementation CacheTimestampResponse


+ (RKObjectMapping *)jsonMapping
{

    RKObjectMapping* entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"ts" : @"timestamp"
     
     }];
    
    
    
    return entityMapping;
}

- (void)applyPostServerActions{
    
}

@end
