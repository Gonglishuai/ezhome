//
//  GetChangedModelsResponse.m
//  Homestyler
//
//  Created by Ma'ayan on 12/3/13.
//
//

#import "GetChangedModelsResponse.h"


@interface GetChangedModelsResponse ()

@property (nonatomic, strong) NSArray *arrModels;

@end


@implementation GetChangedModelsResponse

+(void)initialize
{
}

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"items" : @"arrModels",
     }];
    
    return entityMapping;
}


- (NSArray *)models
{
    return [self.arrModels copy];
}

@end
