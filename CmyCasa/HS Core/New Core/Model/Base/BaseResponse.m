//
//  BaseResponse.m
//  Homestyler
//
//  Created by Yiftach Ringel on 17/06/13.
//
//

#import "BaseResponse.h"

@implementation BaseResponse

// Base mapping
+ (RKObjectMapping*)jsonMapping
{
    RKObjectMapping* entityMapping = [RKObjectMapping mappingForClass:[self class]];
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"er" : @"errorCode",
     @"erMessage" : @"errorMessage"
     }];
    
    return entityMapping;
}

@end
