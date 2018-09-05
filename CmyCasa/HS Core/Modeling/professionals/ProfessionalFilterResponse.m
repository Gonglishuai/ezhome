//
//  ProfessionalFilterResponse.m
//  Homestyler
//
//  Created by Ma'ayan on 12/2/13.
//
//

#import "ProfessionalFilterResponse.h"


@interface ProfessionalFilterResponse ()

@property (nonatomic, strong) NSArray *arrCombos;

@end

@implementation ProfessionalFilterResponse

+(void)initialize
{
    
}

+ (RKObjectMapping *)jsonMapping
{
    RKObjectMapping *entityMapping = [super jsonMapping];
    
    [entityMapping addAttributeMappingsFromDictionary:
     @{
     @"f" : @"arrCombos",
     }];
    
    return entityMapping;
}


- (NSArray *)getCombos
{
    return [self.arrCombos copy];
}


@end
