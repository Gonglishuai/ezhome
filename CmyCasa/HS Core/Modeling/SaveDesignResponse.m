//
//  SaveDesignResponse.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/4/13.
//
//

#import "SaveDesignResponse.h"


@implementation SaveDesignResponse
+ (RKObjectMapping*)jsonMapping
{
    
    
    RKObjectMapping* entityMapping = [super jsonMapping];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
       @"id" : @"designID",
       @"urlBack":@"urlBack",
       @"urlFinal": @"urlFinal",
       @"urlInitial": @"urlInitial",
       @"urlMask": @"urlMask",
       }];
    

    return entityMapping;
}
- (void)applyPostServerActions{
}
@end
